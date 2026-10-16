import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../predictions/predictions_screen.dart';
import 'dash_theme.dart';

class WinProbabilityPanel extends StatelessWidget {
  const WinProbabilityPanel({
    super.key,
    required this.store,
    required this.strings,
    this.selectedDriver,
    this.onSelect,
  });

  final AppContextState store;
  final AppStrings strings;
  final int? selectedDriver;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final meeting = store.forecastMeeting;
    final rows = store.predictions.take(8).toList();
    final maxP = rows.isEmpty ? 1.0 : rows.first.winProbability.clamp(0.0001, 1.0);
    final muted = DashColors.muted(context);
    final sameWeekend = meeting != null && meeting.meetingKey == store.currentMeeting?.meetingKey;
    final rainLabel = meeting == null
        ? strings.rainUnknown
        : sameWeekend
            ? (store.forecastRain ? strings.wetFlag : strings.dryFlag)
            : strings.rainUnknown;

    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(strings.winForecast),
          const SizedBox(height: 6),
          Text(
            meeting?.meetingName ?? strings.formOutlook,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          if (meeting != null)
            Text(
              formatMeetingRange(meeting.dateStart, meeting.dateEnd, isRu: strings.isRu),
              style: TextStyle(color: muted),
            )
          else
            Text(strings.noUpcomingGp, style: TextStyle(color: muted)),
          const SizedBox(height: 4),
          Text(strings.raceWin, style: TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 10),
          if (store.drivers.isEmpty)
            Text(strings.noEntryList)
          else if (rows.isEmpty)
            Text(strings.forecastEmpty)
          else
            for (var i = 0; i < rows.length; i++)
              InkWell(
                onTap: onSelect == null ? null : () => onSelect!(rows[i].driver.driverNumber),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: rows[i].driver.driverNumber == selectedDriver ? AppColors.red : muted,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rows[i].driver.shortName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: rows[i].driver.driverNumber == selectedDriver ? Color(rows[i].driver.teamColorValue) : null,
                              ),
                            ),
                            Text(
                              rows[i].driver.teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: muted, fontSize: 11),
                            ),
                            const SizedBox(height: 3),
                            ProbabilityBar(
                              value: rows[i].winProbability / maxP,
                              color: Color(rows[i].driver.teamColorValue),
                              height: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(percent(rows[i].winProbability), style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 4),
          Text(
            [
              if (store.refreshedAt != null) '${strings.calculatedAt} ${formatClock(store.refreshedAt!, isRu: strings.isRu)}',
              strings.basisLabel(store.forecastBasis),
              '${store.history.length} ${strings.racesUsed}',
              rainLabel,
              if (store.latestSession != null)
                '${strings.entryListFrom}: ${store.latestSession!.year}',
            ].join(' · '),
            style: TextStyle(color: muted, fontSize: 11, height: 1.35),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: Text(strings.predictions)),
                    body: const PredictionsScreen(compact: true),
                  ),
                ),
              ),
              child: Text(strings.viewForecast),
            ),
          ),
        ],
      ),
    );
  }
}
