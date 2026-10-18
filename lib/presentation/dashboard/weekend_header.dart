import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../race_details/race_details_screen.dart';
import 'session_status.dart';

class WeekendHeader extends StatelessWidget {
  const WeekendHeader({
    super.key,
    required this.store,
    required this.live,
    required this.strings,
  });

  final AppContextState store;
  final LiveTimingState live;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final meeting = store.featuredMeeting;
    if (meeting == null) {
      return F1Card(child: Text(strings.noData));
    }
    final status = describeWeekend(
      strings: strings,
      liveSession: store.liveSession,
      latestSession: store.latestSession,
      now: DateTime.now().toUtc(),
    );
    final next = store.nextUpcomingSession;
    final countdown = store.countdown;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RaceDetailsScreen(meeting: meeting)),
      ),
      child: F1Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusBadge(status: status),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    meeting.meetingOfficialName.isEmpty
                        ? meeting.meetingName
                        : meeting.meetingOfficialName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, height: 1.15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${meeting.countryName} · ${meeting.location} · ${meeting.circuitShortName}',
              style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              formatMeetingWhen(meeting.dateStart, isRu: strings.isRu),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (status.sessionLabel.isNotEmpty)
              Text(
                status.sessionLabel,
                style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
              ),
            if (!status.isLive && next != null && countdown != null) ...[
              const SizedBox(height: 6),
              Text(
                '${next.sessionName} · ${formatCountdown(countdown)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              _freshness(),
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _freshness() {
    if (live.streaming) {
      return '${strings.dataFresh} · ${live.transport ?? ''}';
    }
    final updated = live.updatedAt;
    if (updated != null) {
      return '${strings.dataFromSession} · ${updated.toLocal().toIso8601String().substring(11, 19)} UTC';
    }
    final session = store.featuredSession;
    if (session == null) return strings.usingLatestSession;
    return '${strings.usingLatestSession} · ${session.sessionName}';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final WeekendStatus status;

  @override
  Widget build(BuildContext context) {
    final live = status.isLive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: live ? AppColors.red : Theme.of(context).dividerColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (live) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            status.badge,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}
