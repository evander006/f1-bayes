import '../../data/models/openf1_models.dart';
import 'naive_bayes_predictor.dart';

/// Classified winner: finish position 1, a real driver number, not DNS/DSQ.
///
/// Null and non-numeric OpenF1 positions are parsed as 0 and must not win
/// just because they sort ahead of the classified field.
SessionResult? classifiedWinner(List<SessionResult> results) {
  for (final row in results) {
    if (row.position != 1 || row.driverNumber <= 0) continue;
    if (row.dns || row.dsq) continue;
    return row;
  }
  return null;
}

/// Driver number → starting position. Keys are car numbers, never the
/// position itself. Invalid numbers and positions are dropped.
Map<int, int> gridByDriver(Iterable<StartingGrid> rows) {
  final grid = <int, int>{};
  for (final row in rows) {
    if (row.driverNumber <= 0 || row.position <= 0) continue;
    final existing = grid[row.driverNumber];
    if (existing == null || row.position < existing) {
      grid[row.driverNumber] = row.position;
    }
  }
  return grid;
}

/// Qualifying classification used when `/starting_grid` has no rows.
/// Retired codes such as "RT" arrive as position 0 and are not grid slots.
List<StartingGrid> gridFromClassification(
  List<SessionResult> results, {
  required int meetingKey,
  required int sessionKey,
}) {
  final rows = <StartingGrid>[];
  for (final result in results) {
    if (result.driverNumber <= 0 || result.position <= 0) continue;
    if (result.dns || result.dsq) continue;
    rows.add(StartingGrid(
      position: result.position,
      driverNumber: result.driverNumber,
      meetingKey: meetingKey,
      sessionKey: sessionKey,
    ));
  }
  rows.sort((a, b) => a.position.compareTo(b.position));
  return rows;
}

/// Builds one history row. Returns null when the finish order has no
/// trustworthy winner, so a bad payload cannot enter the model.
///
/// A missing starting grid does not drop the race: the winner and the
/// drivers who left the garage are still recorded, and [RaceEvidence.gridPositions]
/// stays empty so the model can treat the grid feature as unobserved.
RaceEvidence? buildRaceEvidence({
  required List<SessionResult> results,
  required List<StartingGrid> startingGrid,
  required bool rain,
}) {
  final winner = classifiedWinner(results);
  if (winner == null) return null;

  final starters = <int>{
    for (final row in results)
      if (row.driverNumber > 0 && !row.dns) row.driverNumber,
  };
  if (!starters.contains(winner.driverNumber)) return null;

  final grid = gridByDriver(startingGrid);
  int? pole;
  for (final entry in grid.entries) {
    if (entry.value == 1) {
      pole = entry.key;
      break;
    }
  }

  final leaderDnf = results.any(
    (row) =>
        row.dnf &&
        row.driverNumber > 0 &&
        (row.position == 1 || row.driverNumber == pole),
  );

  return RaceEvidence(
    winner: winner.driverNumber,
    pole: pole,
    rain: rain,
    leaderDnf: leaderDnf,
    gridPositions: grid,
    starters: starters,
  );
}
