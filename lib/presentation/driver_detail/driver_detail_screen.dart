import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/driver_details_cubit.dart';
import '../bloc/load_status.dart';

class DriverDetailScreen extends StatelessWidget {
  const DriverDetailScreen({super.key, required this.driverNumber});

  final int driverNumber;

  @override
  Widget build(BuildContext context) {
    final session = context.read<AppContextCubit>().state.latestSession;
    return BlocProvider(
      create: (context) {
        final cubit = DriverDetailsCubit(context.read<OpenF1Repository>());
        if (session != null) {
          cubit.load(sessionKey: session.sessionKey, driverNumber: driverNumber);
        }
        return cubit;
      },
      child: _DriverView(driverNumber: driverNumber),
    );
  }
}

class _DriverView extends StatelessWidget {
  const _DriverView({required this.driverNumber});

  final int driverNumber;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final app = context.watch<AppContextCubit>().state;
    final driver = app.driverByNumber(driverNumber);
    final standing = app.driverStandings.where((e) => e.driverNumber == driverNumber);
    final result = app.latestResults.where((e) => e.driverNumber == driverNumber);
    final prediction = app.predictions.where((e) => e.driver.driverNumber == driverNumber);

    if (driver == null) {
      return Scaffold(appBar: AppBar(title: Text(s.driverDetail)), body: Center(child: Text(s.noData)));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(driver.shortName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          F1Card(
            child: Row(
              children: [
                DriverAvatar(driver: driver, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driver.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                      Text('${driver.teamName} · #${driver.driverNumber}', style: const TextStyle(color: AppColors.muted)),
                    ],
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
                Eyebrow(s.championship),
                const SizedBox(height: 8),
                Text('${s.pos}: ${standing.isEmpty ? '—' : standing.first.positionCurrent ?? '—'}'),
                Text('${s.points}: ${standing.isEmpty ? '—' : standing.first.pointsCurrent?.toStringAsFixed(0) ?? '—'}'),
                if (result.isNotEmpty) Text('${s.results}: P${result.first.position}'),
                if (prediction.isNotEmpty) Text('${s.probability}: ${percent(prediction.first.winProbability)}'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<DriverDetailsCubit, DriverDetailsState>(
            builder: (context, state) {
              return F1Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.laps),
                    const SizedBox(height: 8),
                    if (state.status == LoadStatus.loading) const LinearProgressIndicator(),
                    if (state.laps.isEmpty && state.status != LoadStatus.loading) Text(s.noData),
                    for (final lap in state.laps.take(20))
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(width: 40, child: Text('L${lap.lapNumber}', style: const TextStyle(fontWeight: FontWeight.w700))),
                            Expanded(child: Text(formatLap(lap.lapDuration))),
                            Text(formatLap(lap.durationSector1), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text(formatLap(lap.durationSector2), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                            const SizedBox(width: 8),
                            Text(formatLap(lap.durationSector3), style: const TextStyle(color: AppColors.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                    if (state.stints.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Eyebrow(s.stints),
                      for (final stint in state.stints)
                        Text('${stint.compound ?? '—'}  L${stint.lapStart}-${stint.lapEnd ?? '—'}  ${s.tyreAge} ${stint.tyreAgeAtStart ?? '—'}'),
                    ],
                    if (state.pits.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Eyebrow(s.pits),
                      for (final pit in state.pits)
                        Text('${s.lap} ${pit.lapNumber}  ${pit.pitDuration ?? '—'}s'),
                    ],
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
