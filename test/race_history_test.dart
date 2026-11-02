import 'package:f1_app/data/datasources/openf1_api.dart';
import 'package:f1_app/data/models/openf1_models.dart';
import 'package:f1_app/domain/bayes/race_history.dart';
import 'package:flutter_test/flutter_test.dart';

SessionResult _result({
  required int driver,
  required Object? position,
  bool dnf = false,
  bool dns = false,
  bool dsq = false,
}) {
  return SessionResult.fromJson({
    'driver_number': driver,
    'position': position,
    'dnf': dnf,
    'dns': dns,
    'dsq': dsq,
    'meeting_key': 1296,
    'session_key': 11388,
  });
}

void main() {
  test('null finish position is not treated as the winner', () {
    final evidence = buildRaceEvidence(
      results: [
        _result(driver: 18, position: null, dnf: true),
        _result(driver: 43, position: null, dnf: true),
        _result(driver: 3, position: 1),
        _result(driver: 16, position: 2),
      ],
      startingGrid: const [],
      rain: false,
    );

    expect(evidence, isNotNull);
    expect(evidence!.winner, 3);
    expect(evidence.gridPositions, isEmpty);
    expect(evidence.pole, isNull);
    expect(evidence.starters, containsAll([18, 3, 16]));
  });

  test('invalid results are not stored as a race', () {
    expect(
      buildRaceEvidence(
        results: [
          _result(driver: 18, position: null, dnf: true),
          _result(driver: 1, position: 1, dsq: true),
        ],
        startingGrid: const [],
        rain: false,
      ),
      isNull,
    );
    expect(
      buildRaceEvidence(results: const [], startingGrid: const [], rain: false),
      isNull,
    );
  });

  test('grid keys are driver numbers, not positions', () {
    final evidence = buildRaceEvidence(
      results: [
        _result(driver: 44, position: 1),
        _result(driver: 63, position: 2),
      ],
      startingGrid: [
        StartingGrid(position: 1, driverNumber: 63, meetingKey: 1, sessionKey: 2),
        StartingGrid(position: 2, driverNumber: 44, meetingKey: 1, sessionKey: 2),
        StartingGrid(position: 0, driverNumber: 0, meetingKey: 1, sessionKey: 2),
      ],
      rain: false,
    );

    expect(evidence!.winner, 44);
    expect(evidence.pole, 63);
    expect(evidence.gridPositions, {63: 1, 44: 2});
    expect(evidence.gridPositions.containsKey(1), isFalse);
  });

  test('qualifying classification fills a missing starting grid', () {
    final grid = gridFromClassification(
      [
        _result(driver: 3, position: 1),
        _result(driver: 16, position: 2),
        _result(driver: 6, position: 'RT'),
      ],
      meetingKey: 1296,
      sessionKey: 11384,
    );

    expect(grid.map((row) => row.driverNumber).toList(), [3, 16]);
    expect(grid.first.position, 1);
    expect(grid.any((row) => row.driverNumber == 6), isFalse);

    final evidence = buildRaceEvidence(
      results: [
        _result(driver: 16, position: 1),
        _result(driver: 3, position: 2),
      ],
      startingGrid: grid,
      rain: false,
    );
    expect(evidence!.gridPositions[3], 1);
    expect(evidence.gridPositions[16], 2);
    expect(evidence.winner, 16);
    expect(evidence.wonBy(16), isTrue);
    expect(evidence.started(3), isTrue);
    expect(evidence.started(6), isFalse);
  });

  test('a win without a grid is still an observation', () {
    final evidence = buildRaceEvidence(
      results: [
        _result(driver: 5, position: null, dnf: true),
        _result(driver: 81, position: 1),
      ],
      startingGrid: const [],
      rain: false,
    );
    expect(evidence!.wonBy(81), isTrue);
    expect(evidence.wonBy(5), isFalse);
    expect(evidence.started(81), isTrue);
    expect(evidence.started(5), isTrue);
    expect(evidence.gridPositions.containsKey(81), isFalse);
  });

  test('OpenF1 404 no-results payload is an empty collection', () {
    expect(openF1NoResults(404, {'detail': 'No results found.'}), isTrue);
    expect(openF1NoResults(500, {'detail': 'No results found.'}), isFalse);
    expect(openF1NoResults(404, []), isFalse);
  });
}
