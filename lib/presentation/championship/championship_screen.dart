import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../widgets/async_states.dart';

class ChampionshipScreen extends StatelessWidget {
  const ChampionshipScreen({super.key, this.compact = false});

  final bool compact;

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
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 0),
              child: ScreenTitle(title: s.championship),
            ),
            TabBar(
              labelColor: AppColors.red,
              tabs: [Tab(text: s.drivers), Tab(text: s.teams)],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (store.driverStandings.isEmpty) F1Card(child: Text(s.noData)),
                      for (final row in store.driverStandings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: F1Card(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                ),
                                if (store.driverByNumber(row.driverNumber) != null)
                                  DriverAvatar(driver: store.driverByNumber(row.driverNumber)!),
                                const SizedBox(width: 8),
                                Expanded(child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}')),
                                Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                                const SizedBox(width: 8),
                                Text(
                                  _delta(row.positionStart, row.positionCurrent),
                                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (store.teamStandings.isEmpty) F1Card(child: Text(s.noData)),
                      for (final row in store.teamStandings)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: F1Card(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 28,
                                  child: Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                                ),
                                Expanded(child: Text(row.teamName, style: const TextStyle(fontWeight: FontWeight.w700))),
                                Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  String _delta(int? start, int? current) {
    if (start == null || current == null) return '';
    final d = start - current;
    if (d == 0) return '=';
    return d > 0 ? '+$d' : '$d';
  }
}
