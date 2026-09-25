import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/bayes/naive_bayes_predictor.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../driver_detail/driver_detail_screen.dart';
import '../widgets/async_states.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key, this.compact = false});

  final bool compact;

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  bool leaderDnf = false;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
    final rows = leaderDnf
        ? NaiveBayesPredictor().predict(
            drivers: store.drivers,
            history: store.history,
            currentGrid: store.effectiveGrid,
            rain: store.weather?.isWet ?? false,
            assumeLeaderDnf: true,
            championshipPoints: store.championshipPoints,
          )
        : store.predictions;

    return AsyncBody(
      status: store.status,
      strings: s,
      error: store.error,
      onRetry: context.read<AppContextCubit>().load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(widget.compact ? 16 : 28, 16, widget.compact ? 16 : 28, 28),
        children: [
          ScreenTitle(title: s.predictions),
          const SizedBox(height: 16),
          F1Card(
            child: Row(
              children: [
                Expanded(child: Text(s.leaderDnf, style: const TextStyle(fontWeight: FontWeight.w700))),
                Switch(value: leaderDnf, onChanged: (v) => setState(() => leaderDnf = v)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.winProbability),
                const SizedBox(height: 10),
                if (rows.isEmpty) Text(s.noData),
                for (var i = 0; i < rows.length; i++)
                  InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DriverDetailScreen(driverNumber: rows[i].driver.driverNumber),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(width: 24, child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted))),
                          DriverAvatar(driver: rows[i].driver, size: 32),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rows[i].driver.shortName, style: const TextStyle(fontWeight: FontWeight.w700)),
                                ProbabilityBar(value: rows[i].winProbability / 0.4, color: Color(rows[i].driver.teamColorValue)),
                              ],
                            ),
                          ),
                          Text(percent(rows[i].winProbability), style: const TextStyle(fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
