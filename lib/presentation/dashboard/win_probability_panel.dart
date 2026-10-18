import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../driver_detail/driver_detail_screen.dart';
import '../predictions/predictions_screen.dart';

class WinProbabilityPanel extends StatelessWidget {
  const WinProbabilityPanel({
    super.key,
    required this.store,
    required this.strings,
    this.selectedDriverNumber,
  });

  final AppContextState store;
  final AppStrings strings;
  final int? selectedDriverNumber;

  @override
  Widget build(BuildContext context) {
    final meeting = store.nextMeeting ?? store.currentMeeting;
    final rows = store.predictions.take(8).toList();
    final peak = rows.isEmpty ? 1.0 : rows.first.winProbability;
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.predictedWinner, color: AppColors.red),
          const SizedBox(height: 8),
          Text(
            '${strings.predictedFor} ${meeting?.meetingName ?? strings.noData}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (meeting != null)
            Text(
              formatMeetingWhen(meeting.dateStart, isRu: strings.isRu),
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
            ),
          const SizedBox(height: 10),
          if (rows.isEmpty) Text(strings.noWinModel),
          if (rows.isNotEmpty) ...[
            Text(
              rows.first.driver.fullName.isEmpty ? rows.first.driver.shortName : rows.first.driver.fullName,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            Text(rows.first.driver.teamName, style: TextStyle(color: Theme.of(context).hintColor)),
            Text(
              percent(rows.first.winProbability),
              style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800, fontSize: 22),
            ),
            const SizedBox(height: 12),
            for (final row in rows)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DriverDetailScreen(driverNumber: row.driver.driverNumber),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: selectedDriverNumber == row.driver.driverNumber
                        ? AppColors.red.withValues(alpha: 0.1)
                        : null,
                    child: Row(
                      children: [
                        DriverAvatar(driver: row.driver, size: 26),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(row.driver.nameAcronym, style: const TextStyle(fontWeight: FontWeight.w800)),
                              ProbabilityBar(
                                value: peak == 0 ? 0 : (row.winProbability / peak).clamp(0.04, 1),
                                color: Color(row.driver.teamColorValue),
                                height: 6,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(percent(row.winProbability), style: const TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          const SizedBox(height: 8),
          Text(
            strings.winModelHint,
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11, height: 1.3),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PredictionsScreen()),
              ),
              child: Text(strings.predictions),
            ),
          ),
        ],
      ),
    );
  }
}
