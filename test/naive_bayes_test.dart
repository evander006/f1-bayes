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
}
