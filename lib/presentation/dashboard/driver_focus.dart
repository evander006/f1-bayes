import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/dashboard_board_cubit.dart';
import '../driver_detail/driver_detail_screen.dart';
import 'dash_theme.dart';

class DriverFocus extends StatelessWidget {
  const DriverFocus({
    super.key,
    required this.store,
    required this.board,
    required this.strings,
    this.selectedDriver,
  });

  final AppContextState store;
  final BoardState board;
  final AppStrings strings;
  final int? selectedDriver;

  @override
  Widget build(BuildContext context) {
    final driver = selectedDriver == null ? null : store.driverByNumber(selectedDriver!);
    final muted = DashColors.muted(context);
    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: driver == null
          ? Text(strings.selectDriver, style: TextStyle(color: muted))
          : _Body(driver: driver, store: store, board: board, strings: strings),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.driver,
    required this.store,
    required this.board,
    required this.strings,
  });

  final Driver driver;
  final AppContextState store;
  final BoardState board;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final muted = DashColors.muted(context);
    TimingEntry? timing;
    for (final row in board.rows) {
      if (row.driver.driverNumber == driver.driverNumber) timing = row;
    }
    var predictionIndex = -1;
    for (var i = 0; i < store.predictions.length; i++) {
      if (store.predictions[i].driver.driverNumber == driver.driverNumber) {
        predictionIndex = i;
        break;
      }
    }
    ChampionshipDriver? standing;
    for (final row in store.driverStandings) {
      if (row.driverNumber == driver.driverNumber) standing = row;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(strings.selectedDriver),
        const SizedBox(height: 8),
        Row(
          children: [
            DriverAvatar(driver: driver, size: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.fullName.isEmpty ? driver.shortName : driver.fullName, style: const TextStyle(fontWeight: FontWeight.w800)),
                  Text('${driver.teamName} · #${driver.driverNumber}', style: TextStyle(color: muted, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (timing != null) ...[
          _Line(strings.pos, '${timing.position}'),
          _Line(strings.toLeader, timing.gapToLeader ?? '—'),
          _Line(strings.bestLap, formatLap(timing.bestLap)),
          _Line(strings.lastLap, formatLap(timing.lastLap)),
          if (timing.compound != null) _Line(strings.tyre, timing.compound!),
          _Line(strings.status, strings.driverStatusLabel(timing.status)),
        ],
        if (standing?.positionCurrent != null)
          _Line(strings.championship, 'P${standing!.positionCurrent} · ${standing.pointsCurrent?.toStringAsFixed(0) ?? '—'}'),
        if (predictionIndex >= 0)
          _Line(strings.raceWin, '${predictionIndex + 1}. ${percent(store.predictions[predictionIndex].winProbability)}'),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DriverDetailScreen(driverNumber: driver.driverNumber)),
            ),
            child: Text(strings.driverDetail),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: DashColors.muted(context), fontSize: 12))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontFeatures: [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}

class ConditionsCard extends StatelessWidget {
  const ConditionsCard({
    super.key,
    required this.store,
    required this.board,
    required this.strings,
  });

  final AppContextState store;
  final BoardState board;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final weather = store.weather;
    final flag = board.latestFlag;
    if (weather == null && flag == null) return const SizedBox.shrink();
    final muted = DashColors.muted(context);
    final session = store.latestSession?.sessionName ?? '';
    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (weather != null) ...[
            Eyebrow('${strings.conditions} · $session'),
            const SizedBox(height: 8),
            Text(
              weather.airTemperature == null ? '—' : '${weather.airTemperature!.toStringAsFixed(0)}°C',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            Text('${strings.trackTemp} ${weather.trackTemperature?.toStringAsFixed(0) ?? '—'}°C', style: TextStyle(color: muted)),
            Text('${strings.humidity} ${weather.humidity?.toStringAsFixed(0) ?? '—'}%', style: TextStyle(color: muted)),
            Text('${strings.rainfall} ${weather.rainfall ?? 0}', style: TextStyle(color: muted)),
            if (weather.date.millisecondsSinceEpoch > 0)
              Text(formatClock(weather.date, isRu: strings.isRu), style: TextStyle(color: muted, fontSize: 11)),
          ],
          if (flag != null) ...[
            if (weather != null) const SizedBox(height: 10),
            Eyebrow('${strings.flags} · ${board.timingSession?.sessionName ?? session}'),
            const SizedBox(height: 6),
            Text(flag.flag ?? '—', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.red)),
            if (flag.message != null && flag.message!.isNotEmpty)
              Text(flag.message!, style: TextStyle(color: muted, fontSize: 12)),
            Text(formatClock(flag.date, isRu: strings.isRu), style: TextStyle(color: muted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}
