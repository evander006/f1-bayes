import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../widgets/async_states.dart';

class AccuracyScreen extends StatelessWidget {
  const AccuracyScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
    final a = store.accuracy;
    return AsyncBody(
      status: store.status,
      strings: s,
      error: store.error,
      onRetry: context.read<AppContextCubit>().load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
        children: [
          ScreenTitle(title: s.accuracy),
          const SizedBox(height: 16),
          if (a == null)
            F1Card(child: Text(s.noData))
          else ...[
            Row(
              children: [
                Expanded(child: F1Card(child: _metric(s.brierScore, a.brierScore.toStringAsFixed(3)))),
                const SizedBox(width: 12),
                Expanded(child: F1Card(child: _metric(s.hitRate, percent(a.hitRate)))),
              ],
            ),
            const SizedBox(height: 12),
            F1Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(s.predictionVsResult),
                  const SizedBox(height: 10),
                  for (final race in a.byRace)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90,
                            child: Text(
                              DateFormat('d MMM', s.isRu ? 'ru' : 'en').format(race.meeting.dateStart),
                              style: const TextStyle(color: AppColors.muted),
                            ),
                          ),
                          Expanded(child: Text(race.meeting.countryName, style: const TextStyle(fontWeight: FontWeight.w700))),
                          Expanded(
                            child: Text(
                              '${race.predictedWinner.shortName} / ${race.actualWinner.shortName}',
                              style: TextStyle(color: race.hit ? AppColors.hit : null),
                            ),
                          ),
                          Text(race.brierScore.toStringAsFixed(3)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
      },
    );
  }

  Widget _metric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(label),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 28)),
      ],
    );
  }
}
