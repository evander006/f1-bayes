import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/load_status.dart';
import '../bloc/team_details_cubit.dart';
import '../driver_detail/driver_detail_screen.dart';
import '../widgets/async_states.dart';

class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({super.key, required this.teamName});

  final String teamName;

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppContextCubit>().state;
    final roster = app.drivers.where((d) => d.teamName == teamName).toList();
    return BlocProvider(
      create: (context) {
        final cubit = TeamDetailsCubit(context.read<OpenF1Repository>());
        final session = app.latestSession;
        if (session != null) {
          cubit.load(
            sessionKey: session.sessionKey,
            driverNumbers: {for (final d in roster) d.driverNumber},
          );
        }
        return cubit;
      },
      child: _TeamDetailsView(teamName: teamName),
    );
  }
}

class _TeamDetailsView extends StatelessWidget {
  const _TeamDetailsView({required this.teamName});

  final String teamName;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final app = context.watch<AppContextCubit>().state;
    final roster = app.drivers.where((d) => d.teamName == teamName).toList();
    final standing = app.visibleTeams.where((t) => t.teamName == teamName);
    return Scaffold(
      appBar: AppBar(title: Text(teamName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.championship),
                const SizedBox(height: 8),
                Text('${s.pos}: ${standing.isEmpty ? '—' : standing.first.positionCurrent ?? '—'}'),
                Text('${s.points}: ${standing.isEmpty ? '—' : standing.first.pointsCurrent?.toStringAsFixed(0) ?? '—'}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.drivers),
                if (roster.isEmpty) Text(s.noData),
                for (final driver in roster)
                  ListTile(
                    leading: DriverAvatar(driver: driver),
                    title: Text(driver.shortName),
                    subtitle: Text('#${driver.driverNumber}'),
                    trailing: Text(
                      app.predictions
                          .where((p) => p.driver.driverNumber == driver.driverNumber)
                          .map((p) => percent(p.winProbability))
                          .firstOrNull ??
                          '',
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => DriverDetailScreen(driverNumber: driver.driverNumber)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.results),
                for (final driver in roster)
                  for (final result in app.latestResults.where((r) => r.driverNumber == driver.driverNumber))
                    Text('${driver.nameAcronym}: P${result.position}', style: const TextStyle(color: AppColors.muted)),
                if (roster.every((d) => app.latestResults.every((r) => r.driverNumber != d.driverNumber)))
                  Text(s.noData),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<TeamDetailsCubit, TeamDetailsState>(
            builder: (context, state) {
              return F1Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow('${s.pits} · ${s.stints}'),
                    const SizedBox(height: 8),
                    if (state.status == LoadStatus.loading) const LinearProgressIndicator(),
                    if (state.pits.isEmpty && state.stints.isEmpty && state.status != LoadStatus.loading)
                      Text(s.noData),
                    for (final pit in state.pits)
                      Text(
                        '${app.driverByNumber(pit.driverNumber)?.nameAcronym ?? pit.driverNumber}  ${s.lap} ${pit.lapNumber}  ${pit.pitDuration ?? '—'}s',
                      ),
                    for (final stint in state.stints)
                      Text(
                        '${app.driverByNumber(stint.driverNumber)?.nameAcronym ?? stint.driverNumber}  ${stint.compound ?? '—'}  L${stint.lapStart}-${stint.lapEnd ?? '—'}',
                      ),
                    if (state.error != null) Text(errorText(s, state.error)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
