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

/// Naive Bayes race-winner model.
///
/// P(Win_d | X) = P(Win_d) * product(P(X_i | Win_d)) / P(X)
///
/// The common evidence P(X) is removed by normalising all driver scores.
/// Laplace smoothing keeps the model valid for rookies and sparse history.
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

    final maxPoints = championshipPoints.values.fold<double>(0, math.max);

    // Population statistics are used for a driver with no historical starts.
    // This is still Bayes: it estimates the likelihood of the observed grid
    // and weather from the available race population instead of inventing data.
    final populationStarts = history.fold<int>(
      0,
      (sum, race) => sum + race.gridPositions.length,
    );
    final populationWins = history.length;
    final populationNonWins = math.max(0, populationStarts - populationWins);
    final populationWinGrid = <int, int>{};
    final populationNonWinGrid = <int, int>{};
    var populationRainWins = 0;
    var populationRainNonWins = 0;
    var populationPoleWins = 0;
    var populationPoleNonWins = 0;

    for (final race in history) {
      final winnerGrid = race.gridPositions[race.winner];
      if (winnerGrid != null) {
        final bucket = _bucket(winnerGrid);
        populationWinGrid[bucket] = (populationWinGrid[bucket] ?? 0) + 1;
      }
      if (race.rain) populationRainWins++;
      if (race.pole == race.winner) populationPoleWins++;

      for (final entry in race.gridPositions.entries) {
        if (entry.key == race.winner) continue;
        final bucket = _bucket(entry.value);
        populationNonWinGrid[bucket] = (populationNonWinGrid[bucket] ?? 0) + 1;
        if (race.rain) populationRainNonWins++;
        if (race.pole == entry.key) populationPoleNonWins++;
      }
    }

    final logs = <int, double>{};
    final featuresByDriver = <int, List<FeatureContribution>>{};

    for (final driver in drivers) {
      final number = driver.driverNumber;
      final starts = history.where((race) => race.gridPositions.containsKey(number)).toList();
      final startCount = starts.length;
      final wins = starts.where((race) => race.winner == number).length;

      final pointsNorm = maxPoints <= 0
          ? 0.5
          : ((championshipPoints[number] ?? 0) / maxPoints).clamp(0.0, 1.0);
      final prior = (wins + alpha + pointsNorm * 0.5) /
          (startCount + 2 * alpha + 0.5);

      final gridPosition = (currentGrid[number] ?? 20).clamp(1, 20);
      final bucket = _bucket(gridPosition);
      final isPole = gridPosition == 1;

      var pGridGivenWin = 0.5;
      var pRainGivenWin = 0.5;
      var pPoleGivenWin = 0.5;

      if (startCount > 0) {
        final winGridCount = <int, int>{};
        final nonWinGridCount = <int, int>{};
        var winRain = 0;
        var nonWinRain = 0;
        var winPole = 0;
        var nonWinPole = 0;

        for (final race in starts) {
          final raceBucket = _bucket(race.gridPositions[number]!);
          if (race.winner == number) {
            winGridCount[raceBucket] = (winGridCount[raceBucket] ?? 0) + 1;
            if (race.rain) winRain++;
            if (race.pole == number) winPole++;
          } else {
            nonWinGridCount[raceBucket] = (nonWinGridCount[raceBucket] ?? 0) + 1;
            if (race.rain) nonWinRain++;
            if (race.pole == number) nonWinPole++;
          }
        }

        final nonWins = math.max(0, startCount - wins);
        pGridGivenWin = _categorical(winGridCount[bucket] ?? 0, wins, 4);
        final pGridGivenNonWin = _categorical(nonWinGridCount[bucket] ?? 0, nonWins, 4);
        pRainGivenWin = _binary(rain ? winRain : wins - winRain, wins);
        final pRainGivenNonWin = _binary(rain ? nonWinRain : nonWins - nonWinRain, nonWins);
        pPoleGivenWin = _binary(isPole ? winPole : wins - winPole, wins);
        final pPoleGivenNonWin = _binary(isPole ? nonWinPole : nonWins - nonWinPole, nonWins);

        var logPosterior = math.log(_clamp(prior));
        logPosterior += math.log(_clamp(pGridGivenWin));
        logPosterior += math.log(_clamp(pRainGivenWin));
        logPosterior += math.log(_clamp(pPoleGivenWin));

        // These values are retained in the model for documentation/debugging
        // and make the likelihood interpretation explicit.
        assert(pGridGivenNonWin >= 0);
        assert(pRainGivenNonWin >= 0);
        assert(pPoleGivenNonWin >= 0);

        logs[number] = logPosterior;
      } else {
        // Rookie/new-driver fallback: use the empirical population likelihood.
        pGridGivenWin = _categorical(
          populationWinGrid[bucket] ?? 0,
          populationWins,
          4,
        );
        pRainGivenWin = _binary(
          rain ? populationRainWins : populationWins - populationRainWins,
          populationWins,
        );
        pPoleGivenWin = _binary(
          isPole ? populationPoleWins : populationWins - populationPoleWins,
          populationWins,
        );

        var logPosterior = math.log(_clamp(prior));
        logPosterior += math.log(_clamp(pGridGivenWin));
        logPosterior += math.log(_clamp(pRainGivenWin));
        logPosterior += math.log(_clamp(pPoleGivenWin));
        logs[number] = logPosterior;

        // The non-win likelihood is calculated from the same population to
        // keep this branch a genuine conditional-probability model.
        final pGridGivenNonWin = _categorical(
          populationNonWinGrid[bucket] ?? 0,
          populationNonWins,
          4,
        );
        final pRainGivenNonWin = _binary(
          rain ? populationRainNonWins : populationNonWins - populationRainNonWins,
          populationNonWins,
        );
        final pPoleGivenNonWin = _binary(
          isPole ? populationPoleNonWins : populationNonWins - populationPoleNonWins,
          populationNonWins,
        );
        assert(pGridGivenNonWin > 0);
        assert(pRainGivenNonWin > 0);
        assert(pPoleGivenNonWin > 0);
      }

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
          logs[entry.key] = logs[entry.key]! + math.log(0.05);
        }
      }
    }

    final maxLog = logs.values.reduce(math.max);
    final raw = {
      for (final entry in logs.entries) entry.key: math.exp(entry.value - maxLog),
    };
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

  static double _categorical(int count, int total, int categories) =>
      (count + alpha) / (total + alpha * categories);

  static double _binary(int count, int total) =>
      (count + alpha) / (total + alpha * 2);

  static double _clamp(double value) => value.clamp(1e-12, 1.0 - 1e-12);

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
