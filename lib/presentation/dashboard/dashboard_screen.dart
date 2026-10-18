import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../search/search_screen.dart';
import '../widgets/async_states.dart';
import '../widgets/live_timing_table.dart';
import 'overview_cards.dart';
import 'recent_results.dart';
import 'track_panel.dart';
import 'weather_strip.dart';
import 'weekend_header.dart';
import 'win_probability_panel.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.compact = false});

  final bool compact;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? _selectedDriver;

  void _select(int? number) {
    setState(() => _selectedDriver = number);
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
        return AsyncBody(
          status: store.status,
          strings: s,
          error: store.error,
          onRetry: context.read<AppContextCubit>().load,
          child: BlocBuilder<LiveTimingCubit, LiveTimingState>(
            builder: (context, live) {
              final padding = EdgeInsets.fromLTRB(
                widget.compact ? 12 : 20,
                12,
                widget.compact ? 12 : 20,
                24,
              );
              final sessionLabel =
                  '${store.featuredSession?.sessionName ?? ''} · ${store.featuredSession?.location ?? ''}';
              final timing = LiveTimingTable(
                strings: s,
                rows: live.rows.isNotEmpty
                    ? live.rows
                    : [
                        for (final result in store.latestResults)
                          if (store.driverByNumber(result.driverNumber) != null)
                            LiveClassificationRow(
                              driver: store.driverByNumber(result.driverNumber)!,
                              position: result.position,
                            ),
                      ],
                sessionLabel: live.rows.isNotEmpty
                    ? sessionLabel
                    : '${s.results} · ${store.latestSession?.sessionName ?? ''}',
                selectedDriverNumber: _selectedDriver,
                onDriverSelected: _select,
                compact: widget.compact,
              );

              final track = TrackPanel(
                store: store,
                live: live,
                strings: s,
                compact: widget.compact,
                selectedDriverNumber: _selectedDriver,
                onDriverSelected: _select,
              );

              final side = Column(
                children: [
                  WinProbabilityPanel(
                    store: store,
                    strings: s,
                    selectedDriverNumber: _selectedDriver,
                  ),
                  const SizedBox(height: 10),
                  WeatherStrip(store: store, strings: s),
                ],
              );

              return ListView(
                padding: padding,
                children: [
                  ScreenTitle(
                    title: s.dashboard,
                    onSearch: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  WeekendHeader(store: store, live: live, strings: s),
                  const SizedBox(height: 10),
                  RaceOverviewCards(
                    store: store,
                    live: live,
                    strings: s,
                    compact: widget.compact,
                  ),
                  const SizedBox(height: 10),
                  if (widget.compact) ...[
                    track,
                    const SizedBox(height: 10),
                    timing,
                    const SizedBox(height: 10),
                    side,
                    const SizedBox(height: 10),
                    RecentRaceResults(store: store, strings: s),
                    const SizedBox(height: 10),
                    ChampionshipStrip(store: store, strings: s),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              track,
                              const SizedBox(height: 10),
                              timing,
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(flex: 3, child: side),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: RecentRaceResults(store: store, strings: s)),
                        const SizedBox(width: 12),
                        Expanded(child: ChampionshipStrip(store: store, strings: s)),
                      ],
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.onSearch});

  final String title;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        const LocaleToggle(),
        if (onSearch != null) ...[
          const SizedBox(width: 12),
          IconButton(onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
        ],
      ],
    );
  }
}