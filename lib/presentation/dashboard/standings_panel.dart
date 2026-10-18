import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/team_color.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../championship/championship_screen.dart';
import 'dash_theme.dart';

class ChampionshipStandings extends StatelessWidget {
  const ChampionshipStandings({super.key, required this.store, required this.strings});

  final AppContextState store;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final drivers = store.driverStandings.take(8).toList();
    final teams = store.visibleTeams.take(5).toList();
    final muted = DashColors.muted(context);
    final moved = store.driverStandings.where((row) {
      return row.positionStart != null && row.positionCurrent != null && row.positionStart != row.positionCurrent;
    }).take(5);

    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.championship),
          const SizedBox(height: 8),
          if (drivers.isEmpty)
            Text(strings.noData)
          else
            for (final row in drivers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                    _Delta(start: row.positionStart, current: row.positionCurrent),
                    const SizedBox(width: 6),
                    Expanded(child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}')),
                    Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                  ],
                ),
              ),
          const SizedBox(height: 10),
          Text(strings.standingsChange, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (moved.isEmpty)
            Text(strings.noDelta, style: TextStyle(color: muted, fontSize: 12))
          else
            for (final row in moved)
              Text(
                'P${row.positionStart} → P${row.positionCurrent}  ${store.driverByNumber(row.driverNumber)?.nameAcronym ?? '#${row.driverNumber}'}',
                style: const TextStyle(fontSize: 12, fontFeatures: [FontFeature.tabularFigures()]),
              ),
          const SizedBox(height: 10),
          Text(strings.constructors, style: const TextStyle(fontWeight: FontWeight.w700)),
          if (teams.isEmpty)
            Text(strings.noData)
          else
            for (final team in teams)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: parseTeamColor(_teamColor(store, team.teamName)), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(team.teamName, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(team.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                  ],
                ),
              ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(strings.championship)),
                    body: const ChampionshipScreen(compact: true),
                  ),
                ),
              ),
              child: Text(strings.standings),
            ),
          ),
        ],
      ),
    );
  }

  String? _teamColor(AppContextState store, String name) {
    for (final driver in store.drivers) {
      if (driver.teamName == name) return driver.teamColour;
    }
    return null;
  }
}

class _Delta extends StatelessWidget {
  const _Delta({required this.start, required this.current});

  final int? start;
  final int? current;

  @override
  Widget build(BuildContext context) {
    if (start == null || current == null || start == current) {
      return const SizedBox(width: 28);
    }
    final gain = start! - current!;
    final up = gain > 0;
    return SizedBox(
      width: 28,
      child: Text(
        up ? '+$gain' : '$gain',
        style: TextStyle(
          color: up ? AppColors.hit : AppColors.miss,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
