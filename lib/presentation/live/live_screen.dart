import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/track_map.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../bloc/load_status.dart';
import '../dashboard/dashboard_screen.dart';
import '../widgets/async_states.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final app = context.read<AppContextCubit>().state;
        return LiveTimingCubit(context.read<OpenF1Repository>())
          ..start(
            session: app.latestSession,
            drivers: app.drivers,
            fallback: app.latestResults,
          );
      },
      child: BlocListener<AppContextCubit, AppContextState>(
        listenWhen: (prev, next) =>
            prev.latestSession?.sessionKey != next.latestSession?.sessionKey ||
            prev.status != next.status,
        listener: (context, app) {
          if (app.status != LoadStatus.success) return;
          context.read<LiveTimingCubit>().start(
                session: app.latestSession,
                drivers: app.drivers,
                fallback: app.latestResults,
              );
        },
        child: _LiveView(compact: compact),
      ),
    );
  }
}

class _LiveView extends StatelessWidget {
  const _LiveView({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final session = context.read<AppContextCubit>().state.latestSession;
    return BlocBuilder<LiveTimingCubit, LiveTimingState>(
      builder: (context, state) {
        return AsyncBody(
          status: state.status,
          strings: s,
          onRetry: () => context.read<LiveTimingCubit>().refresh(),
          child: ListView(
            padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
            children: [
              ScreenTitle(title: s.liveTracker),
              const SizedBox(height: 12),
              if (state.unavailable)
                F1Card(
                  child: Text(
                    state.unavailableReason == 'subscription' ? s.errorSubscription : s.liveUnavailable,
                  ),
                ),
              if (session != null)
                Text(
                  '${session.sessionName} · ${session.location}',
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
              const SizedBox(height: 12),
              F1Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.classification),
                    const SizedBox(height: 10),
                    if (state.rows.isEmpty) Text(s.noData),
                    for (final row in state.rows)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(width: 28, child: Text('${row.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
                            DriverAvatar(driver: row.driver, size: 28),
                            const SizedBox(width: 8),
                            Expanded(child: Text(row.driver.shortName)),
                            Text(
                              row.interval?.gapToLeader == null
                                  ? (row.position == 1 ? 'LEADER' : '—')
                                  : formatGap(row.interval!.gapToLeader),
                            ),
                            if (row.stint?.compound != null) ...[
                              const SizedBox(width: 8),
                              TyreChip(row.stint!.compound!),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (state.points.isNotEmpty) ...[
                const SizedBox(height: 12),
                F1Card(
                  child: TrackMap(
                    points: state.points,
                    drivers: context.read<AppContextCubit>().state.drivers,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
