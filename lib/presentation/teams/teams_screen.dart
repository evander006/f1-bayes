import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../widgets/async_states.dart';
import 'team_details_screen.dart';

class TeamsScreen extends StatelessWidget {
  const TeamsScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
        final colours = {for (final d in store.drivers) d.teamName: d.teamColorValue};
        final teams = store.visibleTeams;
        return AsyncBody(
          status: store.status,
          strings: s,
          error: store.error,
          onRetry: context.read<AppContextCubit>().load,
          child: ListView(
            padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
            children: [
              ScreenTitle(title: s.teams),
              const SizedBox(height: 16),
              if (teams.isEmpty) F1Card(child: Text(s.noData)),
              for (final standing in teams)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => TeamDetailsScreen(teamName: standing.teamName)),
                    ),
                    child: F1Card(
                      child: Row(
                        children: [
                          TeamFlagBar(color: Color(colours[standing.teamName] ?? 0xFFE10600), height: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${standing.positionCurrent ?? '—'}  ${standing.teamName}',
                                  style: const TextStyle(fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  store.drivers.where((d) => d.teamName == standing.teamName).map((d) => d.nameAcronym).join(' · '),
                                  style: const TextStyle(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            standing.pointsCurrent == null
                                ? '— ${s.points}'
                                : '${standing.pointsCurrent!.toStringAsFixed(0)} ${s.points}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
