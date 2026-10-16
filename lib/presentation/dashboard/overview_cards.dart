import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import 'dash_theme.dart';

class RaceOverviewCards extends StatelessWidget {
  const RaceOverviewCards({super.key, required this.store, required this.strings});

  final AppContextState store;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final tiles = _tiles();
    if (tiles.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100 ? tiles.length.clamp(2, 6) : width >= 640 ? 3 : 2;
        final tileWidth = (width - (columns - 1) * 8) / columns;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tile in tiles) SizedBox(width: tileWidth, child: tile),
          ],
        );
      },
    );
  }

  List<Widget> _tiles() {
    final tiles = <Widget>[];
    final meeting = store.displayedMeeting;
    if (meeting != null) {
      tiles.add(_Metric(label: strings.nextRace, value: meeting.meetingName, hint: meeting.countryName));
      if (meeting.circuitShortName.isNotEmpty) {
        tiles.add(_Metric(label: strings.circuit, value: meeting.circuitShortName, hint: meeting.location));
      }
    }

    final latest = store.latestSession;
    final leader = _leader();
    if (latest != null &&
        latest.isRace &&
        latest.dateEnd.toUtc().isBefore(DateTime.now().toUtc()) &&
        leader != null &&
        leader.numberOfLaps != null) {
      tiles.add(_Metric(
        label: strings.raceLaps,
        value: '${leader.numberOfLaps}',
        hint: latest.sessionName,
      ));
    }
    if (leader != null) {
      final driver = store.driverByNumber(leader.driverNumber);
      tiles.add(_Metric(
        label: strings.leader,
        value: driver?.nameAcronym.isNotEmpty == true ? driver!.nameAcronym : '#${leader.driverNumber}',
        hint: store.latestSession?.sessionName,
      ));
    }

    StartingGrid? pole;
    for (final row in store.latestGrid) {
      if (row.position == 1) pole = row;
    }
    if (pole != null) {
      final driver = store.driverByNumber(pole.driverNumber);
      tiles.add(_Metric(
        label: strings.pole,
        value: driver?.nameAcronym.isNotEmpty == true ? driver!.nameAcronym : '#${pole.driverNumber}',
        hint: strings.qualifyingGrid,
      ));
    }

    if (store.predictions.isNotEmpty && store.forecastMeeting != null) {
      final top = store.predictions.first;
      tiles.add(_Metric(
        label: strings.raceWin,
        value: percent(top.winProbability),
        hint: top.driver.nameAcronym.isEmpty ? top.driver.shortName : top.driver.nameAcronym,
      ));
    }

    if (store.countdown != null && store.nextSession != null) {
      tiles.add(_Metric(
        label: strings.timeToSession,
        value: formatCountdown(store.countdown!, isRu: strings.isRu),
        hint: store.nextSession!.sessionName,
      ));
    }
    return tiles;
  }

  SessionResult? _leader() {
    for (final result in store.latestResults) {
      if (result.position == 1) return result;
    }
    return null;
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (hint != null && hint!.isNotEmpty)
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: DashColors.muted(context), fontSize: 12),
            ),
        ],
      ),
    );
  }
}
