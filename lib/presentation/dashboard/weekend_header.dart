import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/weekend_status.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import 'dash_theme.dart';

class WeekendHeader extends StatelessWidget {
  const WeekendHeader({
    super.key,
    required this.store,
    required this.strings,
    required this.refreshing,
    required this.onRefresh,
    required this.onSearch,
  });

  final AppContextState store;
  final AppStrings strings;
  final bool refreshing;
  final VoidCallback onRefresh;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final meeting = store.displayedMeeting;
    final sessions = meeting?.meetingKey == store.currentMeeting?.meetingKey
        ? store.currentSessions
        : store.upcomingSessions;
    final phase = resolveWeekendPhase(
      sessions: sessions,
      meeting: meeting,
      now: DateTime.now().toUtc(),
    );
    final muted = DashColors.muted(context);

    return F1Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 2, color: AppColors.red),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      strings.dashboard,
                      style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (refreshing)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red),
                      )
                    else
                      IconButton(
                        tooltip: strings.refresh,
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                      ),
                    const LocaleToggle(),
                    IconButton(
                      tooltip: strings.search,
                      onPressed: onSearch,
                      icon: const Icon(Icons.search_rounded, size: 20),
                    ),
                  ],
                ),
                if (meeting == null)
                  Text(strings.noData)
                else ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Code(meeting.countryCode),
                      _PhasePill(live: phase.isLive, label: strings.phaseLabel(phase.code)),
                      if (!phase.isLive)
                        Text(strings.notLive, style: TextStyle(color: muted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meeting.meetingName,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      meeting.circuitShortName,
                      meeting.location,
                      meeting.countryName,
                    ].where((part) => part.isNotEmpty).join(' · '),
                    style: TextStyle(color: muted, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMeetingRange(meeting.dateStart, meeting.dateEnd, isRu: strings.isRu),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 16,
                    runSpacing: 6,
                    children: [
                      if (store.nextSession != null)
                        Text(
                          '${strings.nextSession}: ${store.nextSession!.sessionName}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      if (store.countdown != null)
                        _Countdown(target: DateTime.now().toUtc().add(store.countdown!), strings: strings),
                      if (store.refreshedAt != null)
                        Text(
                          '${strings.updated} ${formatClock(store.refreshedAt!, isRu: strings.isRu)}',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Countdown extends StatefulWidget {
  const _Countdown({required this.target, required this.strings});

  final DateTime target;
  final AppStrings strings;

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.target.difference(DateTime.now().toUtc());
    return Text(
      '${widget.strings.timeToSession} ${formatCountdown(left, isRu: widget.strings.isRu)}',
      style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
    );
  }
}

class _Code extends StatelessWidget {
  const _Code(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    if (code.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: DashColors.line(context)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(code, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.live, required this.label});

  final bool live;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bg = live ? AppColors.red : DashColors.raised(context);
    final fg = live ? Colors.white : DashColors.text(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        live ? 'LIVE · $label' : label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.4),
      ),
    );
  }
}
