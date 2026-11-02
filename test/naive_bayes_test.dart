import 'package:f1_app/data/models/openf1_models.dart';
import 'package:f1_app/domain/bayes/naive_bayes_predictor.dart';
import 'package:flutter_test/flutter_test.dart';

Driver _d(int n, String last) => Driver(
      broadcastName: last,
      driverNumber: n,
      firstName: last,
      fullName: last,
      lastName: last,
      meetingKey: 1,
      nameAcronym: last.substring(0, 3).toUpperCase(),
      sessionKey: 1,
      teamColour: 'E10600',
      teamName: 'Test',
    );

void main() {
  test('probabilities normalize to 1', () {
    final drivers = [_d(1, 'One'), _d(4, 'Four'), _d(16, 'Six')];
    final history = [
      RaceEvidence(winner: 1, pole: 1, rain: false, leaderDnf: false, gridPositions: {1: 1, 4: 2, 16: 3}),
      RaceEvidence(winner: 1, pole: 1, rain: true, leaderDnf: false, gridPositions: {1: 1, 4: 3, 16: 2}),
      RaceEvidence(winner: 4, pole: 4, rain: false, leaderDnf: true, gridPositions: {4: 1, 1: 2, 16: 5}),
    ];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: history,
      currentGrid: {1: 1, 4: 2, 16: 8},
      rain: false,
    );
    final sum = rows.fold<double>(0, (a, b) => a + b.winProbability);
    expect((sum - 1).abs() < 0.0001, true);
    expect(rows.first.driver.driverNumber, 1);
  });

  test('championship points break ties when a driver has no starts', () {
    final drivers = [_d(1, 'One'), _d(4, 'Four'), _d(16, 'Six')];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: const [],
      currentGrid: {1: 1, 4: 2, 16: 20},
      rain: false,
      championshipPoints: {1: 100, 4: 40, 16: 4},
    );
    expect(rows.first.driver.driverNumber, 1);
    expect(rows.last.driver.driverNumber, 16);
    expect(rows.first.winProbability > rows.last.winProbability, true);
  });

  test('empty history without grid or points is a flat prior', () {
    final drivers = [_d(1, 'One'), _d(4, 'Four'), _d(16, 'Six')];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: const [],
      currentGrid: const {},
      rain: false,
    );
    final sum = rows.fold<double>(0, (total, row) => total + row.winProbability);
    expect((sum - 1).abs() < 0.0001, true);
    expect(predictionIsFlat(rows), isTrue);
    expect(rows.every((row) => row.grid.position == 0), isTrue);
  });

  test('missing grid is not replaced with the same position', () {
    final drivers = [_d(1, 'One'), _d(4, 'Four'), _d(16, 'Six')];
    final history = [
      RaceEvidence(
        winner: 1,
        pole: null,
        rain: false,
        leaderDnf: false,
        gridPositions: const {},
        starters: {1, 4, 16},
      ),
      RaceEvidence(
        winner: 1,
        pole: null,
        rain: false,
        leaderDnf: false,
        gridPositions: const {},
        starters: {1, 4, 16},
      ),
      RaceEvidence(
        winner: 4,
        pole: null,
        rain: true,
        leaderDnf: false,
        gridPositions: const {},
        starters: {1, 4, 16},
      ),
    ];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: history,
      currentGrid: const {},
      rain: false,
    );
    final sum = rows.fold<double>(0, (total, row) => total + row.winProbability);
    expect((sum - 1).abs() < 0.0001, true);
    expect(rows.every((row) => row.grid.position == 0), isTrue);
    expect(rows.first.driver.driverNumber, 1);
    expect(predictionIsFlat(rows), isFalse);
    expect(rows.first.winProbability, greaterThan(rows.last.winProbability));
  });

  test('championship points separate drivers when the next grid is unknown', () {
    final drivers = [_d(1, 'One'), _d(4, 'Four'), _d(16, 'Six')];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: const [],
      currentGrid: const {},
      rain: false,
      championshipPoints: {1: 100, 4: 40, 16: 4},
    );
    final sum = rows.fold<double>(0, (total, row) => total + row.winProbability);
    expect((sum - 1).abs() < 0.0001, true);
    expect(rows.map((row) => row.driver.driverNumber).toList(), [1, 4, 16]);
    expect(predictionIsFlat(rows), isFalse);
  });

  test('probabilities stay normalised for a full field', () {
    final drivers = [for (var n = 1; n <= 22; n++) _d(n, 'Drv$n')];
    final rows = NaiveBayesPredictor().predict(
      drivers: drivers,
      history: [
        RaceEvidence(
          winner: 3,
          pole: 3,
          rain: false,
          leaderDnf: false,
          gridPositions: {for (var n = 1; n <= 22; n++) n: n},
          starters: {for (var n = 1; n <= 22; n++) n},
        ),
      ],
      currentGrid: {for (var n = 1; n <= 22; n++) n: n == 22 ? 22 : n},
      rain: false,
      championshipPoints: {3: 300, 1: 200, 16: 10},
    );
    final sum = rows.fold<double>(0, (total, row) => total + row.winProbability);
    expect((sum - 1).abs() < 0.0001, true);
    expect(rows.first.driver.driverNumber, isNot(rows.last.driver.driverNumber));
    expect(rows.firstWhere((row) => row.driver.driverNumber == 22).grid.position, 22);
  });
}
