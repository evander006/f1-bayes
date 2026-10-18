import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/openf1_repository.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/track_panel.dart';
import '../widgets/live_timing_table.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key, this.compact = false});

  final bool compact;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  int? _selectedDriver;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final app = context.watch<AppContextCubit>().state;
    return BlocBuilder<LiveTimingCubit, LiveTimingState>(
      builder: (context, state) {
        return ListView(
          padding: EdgeInsets.fromLTRB(widget.compact ? 12 : 20, 12, widget.compact ? 12 : 20, 24),
          children: [
            ScreenTitle(title: s.liveTracker),
            const SizedBox(height: 8),
            Text(
              switch (state.transport) {
                'mqtt' => s.liveMqtt,
                'websocket' => s.liveWebsocket,
                'rest' => s.liveRestFallback,
                _ => context.read<OpenF1Repository>().isAuthenticated
                    ? s.liveRestFallback
                    : s.errorSubscription,
              },
              style: const TextStyle(color: AppColors.mutedDark),
            ),
            const SizedBox(height: 10),
            TrackPanel(
              store: app,
              live: state,
              strings: s,
              compact: widget.compact,
              selectedDriverNumber: _selectedDriver,
              onDriverSelected: (n) => setState(() => _selectedDriver = n),
            ),
            const SizedBox(height: 10),
            LiveTimingTable(
              strings: s,
              rows: state.rows,
              sessionLabel:
                  '${app.featuredSession?.sessionName ?? ''} · ${app.featuredSession?.location ?? ''}',
              selectedDriverNumber: _selectedDriver,
              onDriverSelected: (n) => setState(() => _selectedDriver = n),
              compact: widget.compact,
            ),
          ],
        );
      },
    );
  }
}
