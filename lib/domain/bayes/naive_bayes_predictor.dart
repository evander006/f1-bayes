import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../data/models/openf1_models.dart';
import '../models/prediction_models.dart';

class RaceEvidence {
  const RaceEvidence({
    required this.winner,
    required this.pole,
    required this.rain,
    required this.leaderDnf,
    required this.gridPositions,
    this.starters = const {},
  });

  final int winner;
  final int? pole;
  final bool rain;
  final bool leaderDnf;

  /// Driver number → starting position. Empty when that race has no grid.
  final Map<int, int> gridPositions;

  /// Drivers who took the start. When empty, [gridPositions] is the fallback.
  final Set<int> starters;

  bool started(int driverNumber) {
    if (driverNumber <= 0) return false;
    if (starters.isNotEmpty) return starters.contains(driverNumber);
    if (gridPositions.isNotEmpty) return gridPositions.containsKey(driverNumber);
    return winner == driverNumber;
  }

  /// A win counts without a grid. A known grid that does not contain the
  /// winner is a mismatched driver number and is not used as an observation.
  bool wonBy(int driverNumber) {
    if (winner != driverNumber || driverNumber <= 0) return false;
    if (starters.isNotEmpty) return starters.contains(driverNumber);
    if (gridPositions.isEmpty) return true;
    return gridPositions.containsKey(driverNumber);
  }
}

/// True when every driver received the same probability.
bool predictionIsFlat(Iterable<DriverPrediction> rows, {double epsilon = 1e-4}) {
  final values = rows.map((row) => row.winProbability).toList();
  if (values.length < 2) return false;
  final first = values.first;
  for (final value in values) {
    if ((value - first).abs() > epsilon) return false;
  }
  return true;
}

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

    final usableGrid = <int, int>{
      for (final entry in currentGrid.entries)
        if (entry.key > 0 && entry.value > 0) entry.key: entry.value,
    };
    final useGrid = usableGrid.isNotEmpty;

    final winsByDriver = <int, int>{};
    final weights = <int, double>{};
    for (final driver in drivers) {
      final number = driver.driverNumber;
      final wins = history.where((race) => race.wonBy(number)).length;
      winsByDriver[number] = wins;
      weights[number] = (wins + alpha) * _pointsFactor(championshipPoints[number] ?? 0);
    }

    final totalPriorWeight = weights.values.fold<double>(0, (sum, value) => sum + value);

    final populationWinGrid = <int, int>{};
    var populationGridObservations = 0;
    var populationRainWins = 0;
    var populationRainObservations = 0;
    var populationPoleWins = 0;
    var populationPoleObservations = 0;

    for (final race in history) {
      if (race.winner <= 0) continue;
      final winnerGrid = race.gridPositions[race.winner];
      if (winnerGrid != null && winnerGrid > 0) {
        final bucket = _bucket(winnerGrid);
        populationWinGrid[bucket] = (populationWinGrid[bucket] ?? 0) + 1;
        populationGridObservations++;
      }
      populationRainObservations++;
      if (race.rain) populationRainWins++;
      if (race.pole != null && race.pole! > 0) {
        populationPoleObservations++;
        if (race.pole == race.winner) populationPoleWins++;
      }
    }

    final logs = <int, double>{};
    final featuresByDriver = <int, List<FeatureContribution>>{};

    for (final driver in drivers) {
      final number = driver.driverNumber;
      final starts = history.where((race) => race.started(number)).toList();
      final startCount = starts.length;
      final wins = winsByDriver[number] ?? 0;
      final prior = totalPriorWeight <= 0 ? 1 / drivers.length : weights[number]! / totalPriorWeight;

      final ownGrid = <int, int>{};
      var ownGridObservations = 0;
      var ownPoleWins = 0;
      var ownPoleObservations = 0;
      var ownRainWins = 0;

      for (final race in starts) {
        if (!race.wonBy(number)) continue;
        final historicalGrid = race.gridPositions[number];
        if (historicalGrid != null && historicalGrid > 0) {
          final historicalBucket = _bucket(historicalGrid);
          ownGrid[historicalBucket] = (ownGrid[historicalBucket] ?? 0) + 1;
          ownGridObservations++;
        }
        if (race.pole != null && race.pole! > 0) {
          ownPoleObservations++;
          if (race.pole == number) ownPoleWins++;
        }
        if (race.rain) ownRainWins++;
      }

      final pRainGivenWin = wins > 0
          ? _binary(rain ? ownRainWins : wins - ownRainWins, wins)
          : _binary(
              rain ? populationRainWins : populationRainObservations - populationRainWins,
              populationRainObservations,
            );

      int? gridPosition;
      var isPole = false;
      if (useGrid) {
        final raw = usableGrid[number];
        if (raw != null && raw > 0) {
          gridPosition = raw;
          isPole = raw == 1;
        }
      }
      final bucket = gridPosition == null ? 3 : _bucket(gridPosition);

      final pGridGivenWin = useGrid
          ? _gridLikelihood(
              bucket: bucket,
              ownCount: ownGrid[bucket] ?? 0,
              ownTotal: ownGridObservations,
              population: populationWinGrid,
              populationTotal: populationGridObservations,
            )
          : null;
      final pPoleGivenWin = useGrid
          ? _poleLikelihood(
              isPole: isPole,
              ownPoleWins: ownPoleWins,
              ownPoleTotal: ownPoleObservations,
              populationPoleWins: populationPoleWins,
              populationPoleTotal: populationPoleObservations,
            )
          : null;

      var logScore = math.log(_clamp(prior));
      logScore += math.log(_clamp(pRainGivenWin));
      if (pGridGivenWin != null) logScore += math.log(_clamp(pGridGivenWin));
      if (pPoleGivenWin != null) logScore += math.log(_clamp(pPoleGivenWin));

      logs[number] = logScore;
      featuresByDriver[number] = [
        FeatureContribution(id: 'prior', weight: prior),
        FeatureContribution(id: 'grid', weight: pGridGivenWin ?? 1),
        FeatureContribution(id: 'rain', weight: pRainGivenWin),
        FeatureContribution(id: 'pole', weight: pPoleGivenWin ?? 1),
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
      for (final entry in usableGrid.entries) {
        if (entry.value == 1 && logs.containsKey(entry.key)) {
          logs[entry.key] = logs[entry.key]! + math.log(0.05);
        }
      }
    }

    final maxLog = logs.values.reduce(math.max);
    final rawScores = {
      for (final entry in logs.entries) entry.key: math.exp(entry.value - maxLog),
    };
    final totalScore = rawScores.values.fold<double>(0, (sum, value) => sum + value);

    final matchedStarts = drivers.fold<int>(
      0,
      (sum, driver) => sum + history.where((race) => race.started(driver.driverNumber)).length,
    );
    final matchedWins = drivers.fold<int>(
      0,
      (sum, driver) => sum + (winsByDriver[driver.driverNumber] ?? 0),
    );
    debugPrint(
      'NaiveBayes: history=${history.length}, '
      'matchedStarts=$matchedStarts, matchedWins=$matchedWins, '
      'grids=${history.where((race) => race.gridPositions.isNotEmpty).length}, '
      'currentGrid=${usableGrid.length}, points=${championshipPoints.length}',
    );
    if (history.isNotEmpty && matchedStarts == 0 && matchedWins == 0) {
      debugPrint(
        'NaiveBayes: история не пустая, но ни один текущий гонщик '
        'не сопоставился с её номерами',
      );
    }

    final rows = [
      for (final driver in drivers)
        DriverPrediction(
          driver: driver,
          winProbability: totalScore <= 0
              ? 1 / drivers.length
              : rawScores[driver.driverNumber]! / totalScore,
          grid: StartingGrid(
            position: usableGrid[driver.driverNumber] ?? 0,
            driverNumber: driver.driverNumber,
            meetingKey: driver.meetingKey,
            sessionKey: driver.sessionKey,
          ),
          features: featuresByDriver[driver.driverNumber] ?? const [],
        ),
    ]..sort((a, b) => b.winProbability.compareTo(a.winProbability));

    for (final row in rows) {
      final number = row.driver.driverNumber;
      debugPrint(
        '${row.driver.broadcastName} (#$number): '
        'starts=${history.where((race) => race.started(number)).length}, '
        'wins=${winsByDriver[number] ?? 0}, '
        'grid=${usableGrid.containsKey(number) ? usableGrid[number] : 'absent'}, '
        'points=${championshipPoints[number] ?? 0}, '
        'p=${row.winProbability.toStringAsFixed(4)}',
      );
    }
    if (predictionIsFlat(rows)) {
      debugPrint(
        'NaiveBayes: недостаточно различающих наблюдений, '
        'априор равномерный (${rows.length} гонщиков)',
      );
    }
    return rows;
  }

  static double _gridLikelihood({
    required int bucket,
    required int ownCount,
    required int ownTotal,
    required Map<int, int> population,
    required int populationTotal,
  }) {
    if (ownTotal > 0) return _categorical(ownCount, ownTotal, 4);
    if (populationTotal > 0) {
      return _categorical(population[bucket] ?? 0, populationTotal, 4);
    }
    return _categorical(0, 0, 4);
  }

  static double _poleLikelihood({
    required bool isPole,
    required int ownPoleWins,
    required int ownPoleTotal,
    required int populationPoleWins,
    required int populationPoleTotal,
  }) {
    if (ownPoleTotal > 0) {
      return _binary(isPole ? ownPoleWins : ownPoleTotal - ownPoleWins, ownPoleTotal);
    }
    if (populationPoleTotal > 0) {
      return _binary(
        isPole ? populationPoleWins : populationPoleTotal - populationPoleWins,
        populationPoleTotal,
      );
    }
    return _binary(0, 0);
  }

  /// Championship points rescale the Laplace prior. Zero points leave it unchanged.
  static double _pointsFactor(double points) {
    if (!points.isFinite || points <= 0) return 1;
    return 1 + math.log(1 + points);
  }

  static double _categorical(int count, int total, int categories) {
    return (count + alpha) / (total + alpha * categories);
  }

  static double _binary(int count, int total) {
    return (count + alpha) / (total + alpha * 2);
  }

  static double _clamp(double value) {
    return value.clamp(1e-12, 1.0 - 1e-12);
  }

  // Starting positions: 1; 2–3; 4–10; 11+.
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
      (sum, race) => sum + teamNumbers.where(race.started).length,
    );
    final wins = history.where((race) => teamNumbers.any(race.wonBy)).length;
    return (wins + alpha) / (starts + alpha * 2);
  }
}
