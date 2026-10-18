import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../data/models/openf1_models.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../domain/weekend_status.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/dashboard_board_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../bloc/load_status.dart';
import '../search/search_screen.dart';
import '../widgets/async_states.dart';
import 'dash_theme.dart';
import 'driver_focus.dart';
import 'overview_cards.dart';
import 'recent_results.dart';
import 'standings_panel.dart';
import 'timing_table.dart';
import 'track_panel.dart';
import 'weekend_header.dart';
import 'win_probability_panel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBoardCubit(context.read<OpenF1Repository>()),
      child: _DashboardHost(compact: compact),
    );
  }
}

class _DashboardHost extends StatefulWidget {
  const _DashboardHost({required this.compact});

  final bool compact;

  @override
  State<_DashboardHost> createState() => _DashboardHostState();
}

class _DashboardHostState extends State<_DashboardHost> {
  int? _selected;
  bool _gridView = false;
  bool _refreshing = false;
  Timer? _phaseTimer;

  @override
  void initState() {
    super.initState();
    _phaseTimer = Timer.periodic(const Duration(seconds: 15), (_) => _syncBoard());
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncBoard());
  }

  @override
  void dispose() {
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _syncBoard() {
    if (!mounted) return;
    final store = context.read<AppContextCubit>().state;
    if (store.status == LoadStatus.success) {
      context.read<DashboardBoardCubit>().load(store);
    }
    setState(() {});
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    await context.read<AppContextCubit>().load();
    if (mounted) setState(() => _refreshing = false);
  }

  Session? _active(AppContextState store) {
    final now = DateTime.now().toUtc();
    return activeSession(store.currentSessions, now) ??
        (store.latestSession != null && sessionIsActive(store.latestSession!, now) ? store.latestSession : null);
  }

  @override
  Widget build(BuildContext context) {
    final strings = LocaleScope.stringsOf(context);
    return BlocListener<AppContextCubit, AppContextState>(
      listenWhen: (previous, next) =>
          previous.status != next.status ||
          previous.refreshedAt != next.refreshedAt ||
          previous.latestSession?.sessionKey != next.latestSession?.sessionKey,
      listener: (context, state) {
        if (state.status == LoadStatus.success) {
          context.read<DashboardBoardCubit>().load(state);
        }
      },
      child: BlocBuilder<AppContextCubit, AppContextState>(
        builder: (context, store) {
          final active = _active(store);
          final page = _DashboardBody(
            compact: widget.compact,
            store: store,
            strings: strings,
            refreshing: _refreshing,
            gridView: _gridView,
            selected: _selected,
            liveAttached: active != null,
            onRefresh: _refresh,
            onSearch: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            onGrid: (value) => setState(() => _gridView = value),
            onSelect: (number) => setState(() {
              _selected = _selected == number ? null : number;
            }),
          );
          return AsyncBody(
            status: store.status,
            strings: strings,
            error: store.error,
            onRetry: _refresh,
            child: active == null
                ? page
                : BlocProvider(
                    key: ValueKey(active.sessionKey),
                    create: (context) => LiveTimingCubit(context.read<OpenF1Repository>())
                      ..start(
                        session: active,
                        drivers: store.drivers,
                        fallback: active.sessionKey == store.latestSession?.sessionKey ? store.latestResults : const [],
                      ),
                    child: page,
                  ),
          );
        },
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({
    required this.compact,
    required this.store,
    required this.strings,
    required this.refreshing,
    required this.gridView,
    required this.selected,
    required this.liveAttached,
    required this.onRefresh,
    required this.onSearch,
    required this.onGrid,
    required this.onSelect,
  });

  final bool compact;
  final AppContextState store;
  final AppStrings strings;
  final bool refreshing;
  final bool gridView;
  final int? selected;
  final bool liveAttached;
  final VoidCallback onRefresh;
  final VoidCallback onSearch;
  final ValueChanged<bool> onGrid;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    if (!liveAttached) {
      return BlocBuilder<DashboardBoardCubit, BoardState>(
        builder: (context, board) => _frame(context, board, null),
      );
    }
    return BlocBuilder<DashboardBoardCubit, BoardState>(
      builder: (context, board) {
        return BlocBuilder<LiveTimingCubit, LiveTimingState>(
          builder: (context, live) => _frame(context, board, live),
        );
      },
    );
  }

  Widget _frame(BuildContext context, BoardState board, LiveTimingState? live) {
    final wide = !compact && MediaQuery.sizeOf(context).width >= 1100;
    final main = Column(
      children: [
        TrackPanel(
          store: store,
          board: board,
          strings: strings,
          compact: !wide,
          live: live,
          selectedDriver: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: 10),
        LiveTimingTable(
          store: store,
          board: board,
          strings: strings,
          compact: !wide,
          gridView: gridView,
          onToggle: onGrid,
          live: live,
          selectedDriver: selected,
          onSelect: onSelect,
        ),
      ],
    );
    final side = Column(
      children: [
        WinProbabilityPanel(
          store: store,
          strings: strings,
          selectedDriver: selected,
          onSelect: onSelect,
        ),
        const SizedBox(height: 10),
        DriverFocus(store: store, board: board, strings: strings, selectedDriver: selected),
        const SizedBox(height: 10),
        ConditionsCard(store: store, board: board, strings: strings),
      ],
    );

    return FadeIn(
      child: ListView(
        padding: EdgeInsets.fromLTRB(wide ? 20 : 12, 12, wide ? 20 : 12, 24),
        children: [
          WeekendHeader(
            store: store,
            strings: strings,
            refreshing: refreshing,
            onRefresh: onRefresh,
            onSearch: onSearch,
          ),
          const SizedBox(height: 10),
          RaceOverviewCards(store: store, strings: strings),
          const SizedBox(height: 10),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 8, child: main),
                const SizedBox(width: 10),
                Expanded(flex: 4, child: side),
              ],
            )
          else ...[
            main,
            const SizedBox(height: 10),
            side,
          ],
          const SizedBox(height: 10),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: RecentRaceResults(store: store, board: board, strings: strings)),
                const SizedBox(width: 10),
                Expanded(child: ChampionshipStandings(store: store, strings: strings)),
              ],
            )
          else ...[
            RecentRaceResults(store: store, board: board, strings: strings),
            const SizedBox(height: 10),
            ChampionshipStandings(store: store, strings: strings),
          ],
        ],
      ),
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
