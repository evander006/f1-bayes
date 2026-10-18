import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/circuit_map.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/dashboard_board_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../bloc/load_status.dart';
import 'dash_theme.dart';

class TrackPanel extends StatelessWidget {
  const TrackPanel({
    super.key,
    required this.store,
    required this.board,
    required this.strings,
    required this.compact,
    this.live,
    this.selectedDriver,
    this.onSelect,
  });

  final AppContextState store;
  final BoardState board;
  final AppStrings strings;
  final bool compact;
  final LiveTimingState? live;
  final int? selectedDriver;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final meeting = store.displayedMeeting;
    final circuitName = meeting?.circuitShortName.isNotEmpty == true
        ? meeting!.circuitShortName
        : board.schematic?.name ?? strings.circuit;
    final canPlot = board.trace.length >= 2;
    final liveCars = !canPlot || live == null ? const <CarPlot>[] : _cars(live!.points, store);
    final snapshotCars = canPlot ? _cars(board.cars, store) : const <CarPlot>[];
    final cars = liveCars.isNotEmpty ? liveCars : snapshotCars;
    final livePositions = liveCars.isNotEmpty && board.timingIsLive;
    final muted = DashColors.muted(context);

    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Eyebrow(strings.trackMap)),
              Text(circuitName, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 4),
          Text(_caption(), style: TextStyle(color: muted, fontSize: 12)),
          if (!livePositions && board.carsTimestamp != null && board.carsSession != null)
            Text(
              '${strings.positionsSnapshot} ${formatClock(board.carsTimestamp!, isRu: strings.isRu)} · ${board.carsSession!.sessionName}',
              style: TextStyle(color: muted, fontSize: 12),
            ),
          if (live != null && board.timingIsLive) ...[
            const SizedBox(height: 4),
            Text(_transport(live!), style: TextStyle(color: muted, fontSize: 12)),
          ],
          const SizedBox(height: 8),
          SizedBox(
            height: compact ? 280 : 460,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: DashColors.raised(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: DashColors.line(context)),
              ),
              child: board.outlineStatus == LoadStatus.loading && !board.hasOutline
                  ? const Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2))
                  : !board.hasOutline
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(strings.noCircuit, textAlign: TextAlign.center),
                          ),
                        )
                      : CircuitMap(
                          trace: board.trace,
                          schematic: board.trace.length >= 2 ? null : board.schematic,
                          cars: cars,
                          selectedDriver: selectedDriver,
                          onSelect: onSelect,
                          animateCars: livePositions,
                          sectorOrigin: board.sectorOrigin,
                          sector1: board.sector1,
                          sector2: board.sector2,
                        ),
            ),
          ),
          if (board.sector1 != null && board.sector2 != null && board.trace.length >= 2) ...[
            const SizedBox(height: 8),
            const Wrap(
              spacing: 12,
              children: [
                _SectorKey(color: Color(0xFFE10600), label: 'S1'),
                _SectorKey(color: Color(0xFFF5C518), label: 'S2'),
                _SectorKey(color: Color(0xFF7DD3C7), label: 'S3'),
              ],
            ),
          ],
          if (cars.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Legend(cars: cars, selected: selectedDriver, onSelect: onSelect),
          ] else if (canPlot) ...[
            const SizedBox(height: 8),
            Text(strings.carPositionsUnavailable, style: TextStyle(color: muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  String _caption() {
    if (board.trace.length >= 2) {
      final session = board.outlineSession;
      final name = session == null ? '' : ' · ${session.sessionName}';
      return '${strings.layoutFromLap}$name';
    }
    if (board.schematic != null) return strings.layoutStatic;
    return strings.noCircuit;
  }

  String _transport(LiveTimingState state) {
    if (state.unavailable) {
      return state.unavailableReason == 'subscription' ? strings.errorSubscription : strings.liveUnavailable;
    }
    final carsAt = _latestStamp(state.points);
    if (carsAt != null) {
      return '${strings.positionsSnapshot} ${formatClock(carsAt, isRu: strings.isRu)}';
    }
    return switch (state.transport) {
      'mqtt' => strings.liveMqtt,
      'websocket' => strings.liveWebsocket,
      'rest' => strings.liveRestFallback,
      _ => strings.liveRestFallback,
    };
  }

  DateTime? _latestStamp(List<LocationPoint> points) {
    DateTime? latest;
    for (final point in points) {
      if (latest == null || point.date.isAfter(latest)) latest = point.date;
    }
    return latest;
  }
}

List<CarPlot> _cars(List<LocationPoint> points, AppContextState store) {
  final latest = <int, LocationPoint>{};
  for (final point in points) {
    final prev = latest[point.driverNumber];
    if (prev == null || point.date.isAfter(prev.date)) latest[point.driverNumber] = point;
  }
  final cars = <CarPlot>[];
  for (final point in latest.values) {
    final driver = store.driverByNumber(point.driverNumber);
    if (driver == null) continue;
    final acronym = driver.nameAcronym.isEmpty ? '#${driver.driverNumber}' : driver.nameAcronym;
    cars.add(CarPlot(
      driverNumber: driver.driverNumber,
      x: point.x,
      y: point.y,
      color: Color(driver.teamColorValue),
      label: '${driver.driverNumber}',
      name: '$acronym ${driver.fullName}',
    ));
  }
  return cars;
}

class _SectorKey extends StatelessWidget {
  const _SectorKey({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.cars, required this.selected, this.onSelect});

  final List<CarPlot> cars;
  final int? selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final sorted = [...cars]..sort((a, b) => a.label.compareTo(b.label));
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final car in sorted)
          InkWell(
            onTap: onSelect == null ? null : () => onSelect!(car.driverNumber),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: car.driverNumber == selected ? car.color : DashColors.line(context),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: car.color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(car.name.split(' ').first, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
