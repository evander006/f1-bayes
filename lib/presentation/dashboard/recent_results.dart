import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../race_details/race_details_screen.dart';

class RecentRaceResults extends StatelessWidget {
  const RecentRaceResults({
    super.key,
    required this.store,
    required this.strings,
  });

  final AppContextState store;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final meeting = store.currentMeeting;
    final results = store.latestResults.take(3).toList();
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.recentRace, color: AppColors.red),
          const SizedBox(height: 8),
          Text(
            '${meeting?.meetingName ?? strings.noData} · ${store.latestSession?.sessionName ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (results.isEmpty) Text(strings.noData),
          for (var i = 0; i < results.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 22,
                    child: Text('P${results[i].position}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                  if (store.driverByNumber(results[i].driverNumber) != null)
                    DriverAvatar(driver: store.driverByNumber(results[i].driverNumber)!, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.driverByNumber(results[i].driverNumber)?.shortName ??
                          '#${results[i].driverNumber}',
                    ),
                  ),
                  Text(results[i].gapToLeader ?? (results[i].position == 1 ? 'LEADER' : '—')),
                ],
              ),
            ),
          if (meeting != null)
            Align(
              alignment: Alignment.centerRight,
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
}

class ChampionshipStrip extends StatelessWidget {
  const ChampionshipStrip({
    super.key,
    required this.store,
    required this.strings,
  });

  final AppContextState store;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final drivers = store.driverStandings.take(5).toList();
    final teams = store.visibleTeams.take(5).toList();
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.championship, color: AppColors.red),
          const SizedBox(height: 10),
          Text(strings.drivers, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (drivers.isEmpty) Text(strings.noData),
          for (final row in drivers)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  Expanded(child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}')),
                  Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(strings.constructorsShort, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          if (teams.isEmpty) Text(strings.noData),
          for (final row in teams)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  Expanded(child: Text(row.teamName)),
                  Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
