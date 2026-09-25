import 'dart:math' as math;

import '../../data/models/openf1_models.dart';
import '../models/prediction_models.dart';

class RaceEvidence {
  const RaceEvidence({
    required this.winner,
    required this.pole,
    required this.rain,
    required this.leaderDnf,
    required this.gridPositions,
  });

  final int winner;
  final int? pole;
  final bool rain;
  final bool leaderDnf;
  final Map<int, int> gridPositions;
}

/// Bayesian model for the probability that each current driver wins the race.
///
/// For every driver d and observed feature vector X:
///
///   P(Win_d | X) = P(Win_d) * P(X | Win_d) / P(X)
///
/// With the naive conditional-independence assumption:
///
///   P(Win_d | X) ∝ P(Win_d) * ∏ P(X_i | Win_d)
///
/// The common evidence P(X) is removed by normalising the scores of all
/// drivers at the end. Laplace smoothing prevents zero probabilities when a
/// driver has a small historical sample. This is the standard Naive Bayes
/// construction rather than a weighted heuristic score.
class NaiveBayesPredictor {
  static const double alpha = 1.0;

  List<DriverPrediction> predict({
    required List<Driver> drivers,
    required List<RaceEvidence> history,
    required Map<int, int> currentGrid,
    required bool rain,
    bool assumeLeaderDnf = false,
    Map<int, double> championshipPoints = const {},
  }) {
    if (drivers.isEmpty) return const [];

    final driverTeam = <int, String>{
      for (final driver in drivers) driver.driverNumber: driver.teamName,
    };
    final maxPoints = championshipPoints.values.fold<double>(0, math.max);

    final logs = <int, double>{};
    final featuresByDriver = <int, List<FeatureContribution>>{};

    for (final driver in drivers) {
      final number = driver.driverNumber;
      final starts = history.where((race) => race.gridPositions.containsKey(number)).toList();
      final startCount = starts.length;
      final wins = starts.where((race) => race.winner == number).length;

      // Prior P(Win_d). A Beta(1,1) prior keeps unseen/new drivers valid.
      // Championship points are incorporated only as weak empirical prior
      // evidence; they never replace the historical race outcome data.
      final pointsNorm = maxPoints <= 0
          ? 0.5
          : ((championshipPoints[number] ?? 0) / maxPoints).clamp(0.0, 1.0);
      final priorWins = wins + alpha + pointsNorm * 0.5;
      final priorTotal = startCount + 2 * alpha + 0.5;
      final prior = priorWins / priorTotal;

      final gridPosition = (currentGrid[number] ?? 20).clamp(1, 20);
      final bucket = _bucket(gridPosition);
      final isPole = gridPosition == 1;

      // P(grid bucket | Win) and P(grid bucket | Not Win).
      final winGridCount = <int, int>{};
      final nonWinGridCount = <int, int>{};
      var winRain = 0;
      var nonWinRain = 0;
      var winPole = 0;
      var nonWinPole = 0;
      var leaderDnfWin = 0;
      var leaderDnfNonWin = 0;

      for (final race in starts) {
        final raceBucket = _bucket(race.gridPositions[number]!);
        if (race.winner == number) {
          winGridCount[raceBucket] = (winGridCount[raceBucket] ?? 0) + 1;
          if (race.rain) winRain++;
          if (race.pole == number) winPole++;
          if (race.leaderDnf && race.pole == number) leaderDnfWin++;
        } else {
          nonWinGridCount[raceBucket] = (nonWinGridCount[raceBucket] ?? 0) + 1;
          if (race.rain) nonWinRain++;
          if (race.pole == number) nonWinPole++;
          if (race.leaderDnf && race.pole == number) leaderDnfNonWin++;
        }
      }

      final winCount = wins;
      final nonWinCount = math.max(0, startCount - wins);
      final pGridGivenWin = _categorical(
        winGridCount[bucket] ?? 0,
        winCount,
        4,
      );
      final pGridGivenNonWin = _categorical(
        nonWinGridCount[bucket] ?? 0,
        nonWinCount,
        4,
      );

      // The wet/dry condition is a feature only when the driver has
      // historical starts. For a new driver it stays neutral at 0.5.
      final pRainGivenWin = _binary(rain ? winRain : winCount - winRain, winCount);
      final pRainGivenNonWin = _binary(
        rain ? nonWinRain : nonWinCount - nonWinRain,
        nonWinCount,
      );

      final pPoleGivenWin = _binary(isPole ? winPole : winCount - winPole, winCount);
      final pPoleGivenNonWin = _binary(
        isPole ? nonWinPole : nonWinCount - nonWinPole,
        nonWinCount,
      );

      var logPosterior = math.log(_clampProbability(prior));
      logPosterior += math.log(_clampProbability(pGridGivenWin));
      logPosterior += math.log(_clampProbability(pRainGivenWin));
      logPosterior += math.log(_clampProbability(pPoleGivenWin));

      // A driver currently starting from pole is affected by the historical
      // DNF signal only when the option is explicitly enabled.
      if (assumeLeaderDnf && isPole) {
        final pDnfGivenWin = _binary(leaderDnfWin, winCount);
        logPosterior += math.log(_clampProbability(pDnfGivenWin));
      }

      // If a driver has no historical starts, use the team prior as a weak
      // fallback rather than manufacturing race history for that driver.
      if (startCount == 0) {
        final teamStarts = history.fold<int>(0, (sum, race) {
          final winnerTeam = driverTeam[race.winner];
          return sum + (winnerTeam == driver.teamName ? 1 : 0);
        });
        final teamWins = history.where((r) => driverTeam[r.winner] == driver.teamName).length;
        final teamRate = (teamWins + alpha) / (teamStarts + 2 * alpha);
        logPosterior += math.log(_clampProbability(0.5 * prior + 0.5 * teamRate));
      }

      logs[number] = logPosterior;
      featuresByDriver[number] = [
        FeatureContribution(id: 'prior', weight: prior),
        FeatureContribution(id: 'grid', weight: pGridGivenWin),
        FeatureContribution(id: 'rain', weight: pRainGivenWin),
        FeatureContribution(id: 'pole', weight: pPoleGivenWin),
        FeatureContribution(
          id: 'form',
          weight: (wins + alpha) / (startCount + alpha * 2),
        ),
        FeatureContribution(
          id: 'team',
          weight: _teamWinRate(driver.teamName, drivers, history),
        ),
      ];
    }

    if (assumeLeaderDnf) {
      for (final entry in currentGrid.entries) {
        if (entry.value == 1 && logs.containsKey(entry.key)) {
          // Explicit scenario: the current pole driver suffers a DNF.
          logs[entry.key] = logs[entry.key]! + math.log(0.05);
        }
      }
    }

    final maxLog = logs.values.reduce(math.max);
    final raw = <int, double>{};
    for (final entry in logs.entries) {
      raw[entry.key] = math.exp(entry.value - maxLog);
    }
    final total = raw.values.fold<double>(0, (sum, value) => sum + value);

    return [
      for (final driver in drivers)
        DriverPrediction(
          driver: driver,
          winProbability: total <= 0 ? 1 / drivers.length : raw[driver.driverNumber]! / total,
          grid: StartingGrid(
            position: currentGrid[driver.driverNumber] ?? 0,
            driverNumber: driver.driverNumber,
            meetingKey: driver.meetingKey,
            sessionKey: driver.sessionKey,
          ),
          features: featuresByDriver[driver.driverNumber] ?? const [],
        ),
    ]..sort((a, b) => b.winProbability.compareTo(a.winProbability));
  }

  static double _categorical(int count, int total, int categories) {
    return (count + alpha) / (total + alpha * categories);
  }

  static double _binary(int count, int total) {
    return (count + alpha) / (total + alpha * 2);
  }

  static double _clampProbability(double value) => value.clamp(1e-12, 1.0 - 1e-12);

  static int _bucket(int position) {
    if (position <= 1) return 0;
    if (position <= 3) return 1;
    if (position <= 10) return 2;
    return 3;
  }

  static double _teamWinRate(
    String team,
    List<Driver> drivers,
    List<RaceEvidence> history,
  ) {
    final teamNumbers = {
      for (final driver in drivers)
        if (driver.teamName == team) driver.driverNumber,
    };
    final starts = history.fold<int>(
      0,
      (sum, race) => sum + race.gridPositions.keys.where(teamNumbers.contains).length,
    );
    final wins = history.where((race) => teamNumbers.contains(race.winner)).length;
    return (wins + alpha) / (starts + alpha * 2);
  }
}
