import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/dashboard_board_cubit.dart';
import '../race_details/race_details_screen.dart';
import 'dash_theme.dart';

class RecentRaceResults extends StatelessWidget {
  const RecentRaceResults({
    super.key,
    required this.store,
    required this.board,
    required this.strings,
  });

  final AppContextState store;
  final BoardState board;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final session = board.previousSession;
    final meeting = board.previousMeeting ?? _meeting(store, session);
    final results = board.previousResults.isNotEmpty ? board.previousResults : store.latestResults;
    final grid = board.previousGrid.isNotEmpty ? board.previousGrid : store.latestGrid;
    final muted = DashColors.muted(context);
    final podium = results.take(3).toList();

    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.previousGp),
          const SizedBox(height: 6),
          Text(
            meeting?.meetingName ?? session?.circuitShortName ?? strings.results,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (session != null)
            Text(
              '${session.sessionName} · ${formatMeetingWhen(session.dateStart, isRu: strings.isRu)}',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          const SizedBox(height: 8),
          Text(strings.podium, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (podium.isEmpty)
            Text(strings.noData)
          else
            for (final row in podium) _ResultLine(store: store, result: row),
          if (grid.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(strings.qualifying, style: const TextStyle(fontWeight: FontWeight.w700)),
            for (final row in grid.take(3))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(width: 28, child: Text('P${row.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
                    Expanded(child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}')),
                    Text(formatLap(row.lapDuration)),
                  ],
                ),
              ),
          ],
          if (meeting != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => RaceDetailsScreen(meeting: meeting)),
                ),
                child: Text(strings.viewResults),
              ),
            ),
        ],
      ),
    );
  }

  Meeting? _meeting(AppContextState store, Session? session) {
    if (session == null) return store.currentMeeting;
    for (final meeting in store.meetings) {
      if (meeting.meetingKey == session.meetingKey) return meeting;
    }
    return store.currentMeeting;
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.store, required this.result});

  final AppContextState store;
  final SessionResult result;

  @override
  Widget build(BuildContext context) {
    final driver = store.driverByNumber(result.driverNumber);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text('${result.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
          if (driver != null) DriverAvatar(driver: driver, size: 26),
          const SizedBox(width: 8),
          Expanded(child: Text(driver?.shortName ?? '#${result.driverNumber}')),
          Text(result.dnf ? 'DNF' : (result.gapToLeader ?? (result.position == 1 ? 'LEADER' : '—'))),
        ],
      ),
    );
  }
}
