import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import 'session_status.dart';

class RaceOverviewCards extends StatelessWidget {
  const RaceOverviewCards({
    super.key,
    required this.store,
    required this.live,
    required this.strings,
    required this.compact,
  });

  final AppContextState store;
  final LiveTimingState live;
  final AppStrings strings;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final meeting = store.featuredMeeting;
    final cards = <Widget>[
      _Kpi(
        label: strings.nextGrandPrix,
        value: meeting?.meetingName ?? strings.noData,
        hint: meeting == null ? null : '${meeting.location} · ${meeting.year}',
      ),
      _Kpi(
        label: strings.circuit,
        value: meeting?.circuitShortName.isNotEmpty == true
            ? meeting!.circuitShortName
            : strings.noData,
        hint: meeting?.countryName,
      ),
      _Kpi(
        label: strings.lastLeader,
        value: _leaderName(),
        hint: _leaderHint(),
      ),
      _Kpi(
        label: strings.predictedWinner,
        value: store.predictions.isEmpty ? strings.noData : store.predictions.first.driver.shortName,
        hint: store.predictions.isEmpty ? null : percent(store.predictions.first.winProbability),
      ),
      _Kpi(
        label: strings.timeToSession,
        value: store.countdown == null ? strings.noData : formatCountdown(store.countdown!),
        hint: store.nextUpcomingSession?.sessionName,
      ),
    ];

    if (compact) {
      return SizedBox(
        height: 96,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => SizedBox(width: 180, child: cards[i]),
        ),
      );
    }
    return Row(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: cards[i]),
        ],
      ],
    );
  }

  String _leaderName() {
    if (live.rows.isNotEmpty) return live.rows.first.driver.shortName;
    if (store.latestResults.isEmpty) return strings.noData;
    return store.driverByNumber(store.latestResults.first.driverNumber)?.shortName ??
        '#${store.latestResults.first.driverNumber}';
  }

  String? _leaderHint() {
    if (live.rows.isNotEmpty) return store.liveSession?.sessionName ?? store.latestSession?.sessionName;
    return store.latestSession?.sessionName;
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value, this.hint});

  final String label;
  final String value;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label, color: AppColors.mutedDark),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (hint != null)
            Text(
              hint!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
            ),
        ],
      ),
    );
  }
}
