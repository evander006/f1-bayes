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

class NaiveBayesPredictor {
  static const alpha = 1.0;

  List<DriverPrediction> predict({
    required List<Driver> drivers,
    required List<RaceEvidence> history,
    required Map<int, int> currentGrid,
    required bool rain,
    bool assumeLeaderDnf = false,
    Map<int, double> championshipPoints = const {},
  }) {
    if (drivers.isEmpty) return const [];

    final nRaces = history.length;
    final wins = <int, int>{};
    final teamWins = <String, int>{};
    final driverTeam = {for (final d in drivers) d.driverNumber: d.teamName};
    var poleWins = 0;
    var rainWins = 0;
    var leaderDnfWins = 0;
    final bucketWins = <int, int>{0: 0, 1: 0, 2: 0, 3: 0};

    for (final race in history) {
      wins[race.winner] = (wins[race.winner] ?? 0) + 1;
      final team = driverTeam[race.winner];
      if (team != null) teamWins[team] = (teamWins[team] ?? 0) + 1;
      if (race.pole == race.winner) poleWins++;
      if (race.rain) rainWins++;
      if (race.leaderDnf) leaderDnfWins++;
      final grid = race.gridPositions[race.winner];
      if (grid != null) {
        final bucket = _bucket(grid);
        bucketWins[bucket] = (bucketWins[bucket] ?? 0) + 1;
      }
    }

    final maxPoints = championshipPoints.values.fold<double>(0, math.max);

    final logs = <int, double>{};
    for (final driver in drivers) {
      final n = driver.driverNumber;
      final winCount = (wins[n] ?? 0).toDouble();
      final teamWinCount = (teamWins[driver.teamName] ?? 0).toDouble();
      final points = championshipPoints[n] ?? 0;
      var priorCount = winCount + 0.35 * teamWinCount;
      if (maxPoints > 0) {
        priorCount += points / maxPoints;
      }
      final prior = _smooth(priorCount, nRaces.toDouble() + 1, drivers.length);

      final gridPos = (currentGrid[n] ?? 20).clamp(1, 20);
      final onPole = gridPos == 1;
      final gridBucket = _bucket(gridPos);

      var logP = math.log(prior);
      // Front of the grid is structurally more likely to win, even with no history.
      logP += math.log((21 - gridPos) / 210);

      if (nRaces > 0) {
        logP += math.log(_smooth(
          onPole ? poleWins.toDouble() : (nRaces - poleWins).toDouble(),
          nRaces.toDouble(),
          2,
        ));
        logP += math.log(_smooth(
          rain ? rainWins.toDouble() : (nRaces - rainWins).toDouble(),
          nRaces.toDouble(),
          2,
        ));
        logP += math.log(_smooth(
          (bucketWins[gridBucket] ?? 0).toDouble(),
          nRaces.toDouble(),
          4,
        ));
        if (assumeLeaderDnf) {
          logP += math.log(_smooth(leaderDnfWins.toDouble(), nRaces.toDouble(), 2));
        }
      }
      logs[n] = logP;
    }

    if (assumeLeaderDnf) {
      for (final entry in currentGrid.entries) {
        if (entry.value == 1 && logs.containsKey(entry.key)) {
          logs[entry.key] = logs[entry.key]! + math.log(0.05);
        }
      }
    }

    final maxLog = logs.values.reduce(math.max);
    final raw = {for (final e in logs.entries) e.key: math.exp(e.value - maxLog)};
    final sum = raw.values.fold<double>(0, (a, b) => a + b);

    return [
      for (final driver in drivers)
        DriverPrediction(
          driver: driver,
          winProbability: sum == 0 ? 0 : (raw[driver.driverNumber] ?? 0) / sum,
          grid: StartingGrid(
            position: currentGrid[driver.driverNumber] ?? 0,
            driverNumber: driver.driverNumber,
            meetingKey: driver.meetingKey,
            sessionKey: driver.sessionKey,
          ),
          features: [
            FeatureContribution(
              id: 'pole',
              weight: currentGrid[driver.driverNumber] == 1 ? 1 : 0.2,
            ),
            FeatureContribution(
              id: 'grid',
              weight: 1 - (((currentGrid[driver.driverNumber] ?? 20) - 1) / 19).clamp(0, 1),
            ),
            FeatureContribution(
              id: 'rain',
              weight: rain ? 0.6 : 0.3,
            ),
            FeatureContribution(
              id: 'form',
              weight: _ratio(wins[driver.driverNumber], nRaces),
            ),
            FeatureContribution(
              id: 'team',
              weight: _ratio(teamWins[driver.teamName], nRaces),
            ),
          ],
        ),
    ]..sort((a, b) => b.winProbability.compareTo(a.winProbability));
  }

  static int _bucket(int pos) {
    if (pos <= 1) return 0;
    if (pos <= 3) return 1;
    if (pos <= 10) return 2;
    return 3;
  }

  static double _smooth(double count, double n, int k) =>
      (count + alpha) / ((n < 0 ? 0 : n) + alpha * k);

  static double _ratio(int? part, int? total) {
    if (total == null || total == 0) return 0.15;
    return ((part ?? 0) + alpha) / (total + alpha * 2);
  }
}
