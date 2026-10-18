import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/track_map.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../driver_detail/driver_detail_screen.dart';

class TrackPanel extends StatelessWidget {
  const TrackPanel({
    super.key,
    required this.store,
    required this.live,
    required this.strings,
    required this.compact,
    required this.selectedDriverNumber,
    required this.onDriverSelected,
  });

  final AppContextState store;
  final LiveTimingState live;
  final AppStrings strings;
  final bool compact;
  final int? selectedDriverNumber;
  final ValueChanged<int?> onDriverSelected;

  @override
  Widget build(BuildContext context) {
    final liveGps = live.points.length >= 8;
    final sameCircuit = store.trackOutlineSession?.circuitKey ==
        store.featuredSession?.circuitKey;
    final selected = selectedDriverNumber == null
        ? null
        : store.driverByNumber(selectedDriverNumber!) ??
            _fromLive(selectedDriverNumber!);
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(strings.trackMap, color: AppColors.red),
              const Spacer(),
              Text(
                liveGps ? strings.carsOnTrack : strings.trackOutlineOnly,
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _caption(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (!liveGps && (!sameCircuit || store.trackOutline.isEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Text(strings.noData),
            )
          else
            TrackMap(
              points: live.points,
              outline: liveGps || !sameCircuit ? const [] : store.trackOutline,
              drivers: store.drivers,
              compact: compact,
              showCars: liveGps,
              selectedDriverNumber: selectedDriverNumber,
              onDriverSelected: onDriverSelected,
            ),
          if (liveGps) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                for (final driver in _driversOnTrack())
                  GestureDetector(
                    onTap: () => onDriverSelected(driver.driverNumber),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(driver.teamColorValue),
                            shape: BoxShape.circle,
                            border: selectedDriverNumber == driver.driverNumber
                                ? Border.all(color: Colors.white, width: 1.5)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          driver.nameAcronym,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: selectedDriverNumber == driver.driverNumber ? AppColors.red : null,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (!liveGps && sameCircuit && store.trackOutlineSession != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${strings.startFinish} · ${store.trackOutlineSession!.location} ${store.trackOutlineSession!.sessionName} ${store.trackOutlineSession!.year}',
                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11),
              ),
            ),
          if (selected != null) ...[
            const SizedBox(height: 10),
            InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => DriverDetailScreen(driverNumber: selected.driverNumber),
                ),
              ),
              child: Row(
                children: [
                  DriverAvatar(driver: selected, size: 32),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(selected.shortName, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(selected.teamName, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('#${selected.driverNumber}', style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(strings.tapDriver, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 11)),
            ),
        ],
      ),
    );
  }

  String _caption() {
    if (live.points.length >= 8) {
      final session = store.liveSession ?? store.latestSession;
      return '${session?.location ?? ''} · ${session?.sessionName ?? ''}';
    }
    final outline = store.trackOutlineSession;
    if (outline != null) {
      return '${outline.location} · ${outline.sessionName} ${outline.year}';
    }
    final session = store.featuredSession;
    return session == null ? '' : '${session.location} · ${session.sessionName}';
  }

  List<Driver> _driversOnTrack() {
    final numbers = <int>{};
    for (final p in live.points) {
      numbers.add(p.driverNumber);
    }
    return [
      for (final n in numbers)
        if (store.driverByNumber(n) != null) store.driverByNumber(n)!,
    ];
  }

  Driver? _fromLive(int number) {
    for (final row in live.rows) {
      if (row.driver.driverNumber == number) return row.driver;
    }
    return null;
  }
}
