import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/ui_kit.dart';

class DriverDetailScreen extends StatelessWidget {
  const DriverDetailScreen({super.key, required this.prediction});

  final DriverPrediction prediction;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final d = prediction.driver;
    final color = Color(d.teamColorValue);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(s.driverDetail),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: LocaleToggle(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          F1Card(
            child: Row(
              children: [
                DriverAvatar(driver: d, size: 64),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.shortName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                      Text('${d.teamName}  ·  #${d.driverNumber}', style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    'P${prediction.grid.position}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.winProbability),
                const SizedBox(height: 8),
                Text(
                  percent(prediction.winProbability),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 36),
                ),
                const SizedBox(height: 8),
                ProbabilityBar(value: prediction.winProbability / 0.4, color: color, height: 10),
              ],
            ),
          ),
          const SizedBox(height: 14),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.history),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final item in const ['BHR', 'SAU', 'JPN', 'CHN', 'MCO'])
                      Column(
                        children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: item == 'MCO' ? AppColors.red : const Color(0xFFD1D5DB),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(item, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          F1Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.featureContribution),
                const SizedBox(height: 16),
                for (final f in prediction.features) ...[
                  Row(
                    children: [
                      SizedBox(width: 120, child: Text(s.featureLabel(f.id))),
                      Expanded(child: ProbabilityBar(value: f.weight, color: color)),
                      const SizedBox(width: 8),
                      Text('${(f.weight * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
