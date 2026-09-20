import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_openf1.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/track_map.dart';
import '../../widgets/ui_kit.dart';
import '../dashboard/dashboard_screen.dart';

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key, this.compact = false});

  final bool compact;

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final data = MockOpenF1.snapshot;
    final selected = data.classification[selectedIndex];

    if (widget.compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _SelectedDriverCard(s: s, data: data, row: selected),
          const SizedBox(height: 12),
          F1Card(
            padding: const EdgeInsets.all(12),
            child: TrackMap(points: data.trackLocations, drivers: data.drivers),
          ),
          const SizedBox(height: 12),
          _ClassificationCard(
            s: s,
            data: data,
            selectedIndex: selectedIndex,
            onSelect: (i) => setState(() => selectedIndex = i),
            compact: true,
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      child: Column(
        children: [
          ScreenTitle(title: s.liveTracker),
          const SizedBox(height: 22),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: _ClassificationCard(
                    s: s,
                    data: data,
                    selectedIndex: selectedIndex,
                    onSelect: (i) => setState(() => selectedIndex = i),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: Column(
                    children: [
                      _SelectedDriverCard(s: s, data: data, row: selected),
                      const SizedBox(height: 16),
                      Expanded(
                        child: F1Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Eyebrow(s.trackMap),
                                  const Spacer(),
                                  Text(
                                    '${s.lap} ${data.leaderLap.lapNumber} / ${data.totalLaps}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: TrackMap(
                                  points: data.trackLocations,
                                  drivers: data.drivers,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: _QualiCard(s: s, data: data),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassificationCard extends StatelessWidget {
  const _ClassificationCard({
    required this.s,
    required this.data,
    required this.selectedIndex,
    required this.onSelect,
    this.compact = false,
  });

  final AppStrings s;
  final MockSnapshot data;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final list = ListView.separated(
      shrinkWrap: compact,
      physics: compact ? const NeverScrollableScrollPhysics() : null,
      itemCount: data.classification.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, i) {
        final row = data.classification[i];
        final selected = i == selectedIndex;
        return InkWell(
          onTap: () => onSelect(i),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF7F8FB) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    '${row.position.position}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                TeamFlagBar(color: Color(row.driver.teamColorValue)),
                const SizedBox(width: 8),
                DriverAvatar(driver: row.driver, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.driver.shortName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                SizedBox(
                  width: 64,
                  child: Text(
                    formatGap(row.interval.gapToLeader),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                TyreChip(row.stint.compound),
              ],
            ),
          ),
        );
      },
    );

    return F1Card(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(compact ? '${s.live} ${s.classification}' : s.classification),
          if (!compact)
            const Padding(
              padding: EdgeInsets.only(right: 12, top: 12, bottom: 8),
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('#', style: _head)),
                  Expanded(child: Text('Driver', style: _head)),
                  SizedBox(width: 64, child: Text('Gap', style: _head)),
                  SizedBox(width: 28, child: Text('Ty', style: _head)),
                ],
              ),
            )
          else
            const SizedBox(height: 8),
          if (compact) list else Expanded(child: list),
        ],
      ),
    );
  }
}

const _head = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.muted,
  letterSpacing: 0.4,
);

class _SelectedDriverCard extends StatelessWidget {
  const _SelectedDriverCard({
    required this.s,
    required this.data,
    required this.row,
  });

  final AppStrings s;
  final MockSnapshot data;
  final LiveClassificationRow row;

  @override
  Widget build(BuildContext context) {
    final speed = row.position.position == 1
        ? data.leaderCarData.speed
        : data.leaderCarData.speed - row.position.position * 4;
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DriverAvatar(driver: row.driver, size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(s.selectedDriver),
                    Text(
                      row.driver.shortName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    Text(
                      row.driver.teamName,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'P${row.position.position}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Stat(s.speed, '$speed', 'km/h'),
              _Stat(s.gap, formatGap(row.interval.gapToLeader), 's'),
              _Stat(s.tyre, row.stint.compound[0], row.stint.compound),
              _Stat(s.lap, '${data.leaderLap.lapNumber}', '/ ${data.totalLaps}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.unit);

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          Text(unit, style: const TextStyle(color: AppColors.muted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _QualiCard extends StatelessWidget {
  const _QualiCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.qualifyingGrid),
          const SizedBox(height: 8),
          const Row(
            children: [
              SizedBox(width: 24, child: Text('#', style: _head)),
              Expanded(child: Text('Q1   Q2   Q3', style: _head)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: data.qualifyingResults.length,
              itemBuilder: (context, i) {
                final q = data.qualifyingResults[i];
                final driver = data.driverByNumber(q.driverNumber);
                final times = q.qualifyingDurations ?? const [];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        child: Text(
                          '${q.position}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      DriverAvatar(driver: driver, size: 26),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          driver.shortName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                      Text(
                        formatLap(times.isEmpty ? null : times.last),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
