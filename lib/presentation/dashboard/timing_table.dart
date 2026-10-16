import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/dashboard_board_cubit.dart';
import '../bloc/live_timing_cubit.dart';
import '../bloc/load_status.dart';
import 'dash_theme.dart';

class LiveTimingTable extends StatelessWidget {
  const LiveTimingTable({
    super.key,
    required this.store,
    required this.board,
    required this.strings,
    required this.compact,
    required this.gridView,
    required this.onToggle,
    this.live,
    this.selectedDriver,
    this.onSelect,
  });

  final AppContextState store;
  final BoardState board;
  final AppStrings strings;
  final bool compact;
  final bool gridView;
  final ValueChanged<bool> onToggle;
  final LiveTimingState? live;
  final int? selectedDriver;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final session = board.timingSession ?? store.latestSession;
    final rows = gridView ? const <TimingEntry>[] : _displayRows(board, live);
    final muted = DashColors.muted(context);
    return F1Card(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Eyebrow(gridView ? strings.gridView : strings.timingView),
                  if (session != null)
                    Text(
                      '${session.sessionName} · ${session.circuitShortName}'
                      '${board.timingIsLive ? '' : ' · ${strings.usingLatestSession}'}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                ],
              ),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text(strings.timingView)),
                  ButtonSegment(value: true, label: Text(strings.gridView)),
                ],
                selected: {gridView},
                onSelectionChanged: (value) => onToggle(value.first),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (board.timingStatus == LoadStatus.loading && rows.isEmpty && !gridView)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: AppColors.red, strokeWidth: 2)),
            )
          else if (gridView)
            _GridBody(
              store: store,
              strings: strings,
              compact: compact,
              selectedDriver: selectedDriver,
              onSelect: onSelect,
            )
          else if (rows.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(strings.noData))
          else if (compact)
            _Cards(rows: rows, strings: strings, board: board, selected: selectedDriver, onSelect: onSelect)
          else
            _Table(rows: rows, strings: strings, board: board, selected: selectedDriver, onSelect: onSelect),
        ],
      ),
    );
  }
}

List<TimingEntry> _displayRows(BoardState board, LiveTimingState? live) {
  final liveRows = live?.rows ?? const [];
  if (!board.timingIsLive || liveRows.isEmpty) return board.rows;
  final prior = {for (final row in board.rows) row.driver.driverNumber: row};
  return [
    for (final row in liveRows)
      TimingEntry(
        driver: row.driver,
        position: row.position,
        gapToLeader: row.position == 1 ? 'LEADER' : (row.interval?.gapToLeaderLabel ?? prior[row.driver.driverNumber]?.gapToLeader),
        interval: row.position == 1 ? 'LEADER' : (row.interval?.intervalLabel ?? prior[row.driver.driverNumber]?.interval),
        bestLap: prior[row.driver.driverNumber]?.bestLap,
        lastLap: row.bestLap?.lapDuration ?? prior[row.driver.driverNumber]?.lastLap,
        sector1: row.bestLap?.durationSector1 ?? prior[row.driver.driverNumber]?.sector1,
        sector2: row.bestLap?.durationSector2 ?? prior[row.driver.driverNumber]?.sector2,
        sector3: row.bestLap?.durationSector3 ?? prior[row.driver.driverNumber]?.sector3,
        compound: row.stint?.compound ?? prior[row.driver.driverNumber]?.compound,
        laps: prior[row.driver.driverNumber]?.laps,
        status: _liveStatus(prior[row.driver.driverNumber]),
      ),
  ];
}

String _liveStatus(TimingEntry? prior) {
  if (prior == null) return 'on_track';
  if (prior.status == 'retired' || prior.status == 'dns' || prior.status == 'dsq') return prior.status;
  return 'on_track';
}

class _Table extends StatelessWidget {
  const _Table({
    required this.rows,
    required this.strings,
    required this.board,
    required this.selected,
    this.onSelect,
  });

  final List<TimingEntry> rows;
  final AppStrings strings;
  final BoardState board;
  final int? selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final muted = DashColors.muted(context);
    final header = TextStyle(color: muted, fontSize: 11, fontWeight: FontWeight.w700);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 980),
        child: Column(
          children: [
            Row(
              children: [
                _h(strings.pos, 36, header),
                _h(strings.numberSign, 36, header),
                _h(strings.driver, 150, header),
                _h(strings.teamCol, 130, header),
                _h(strings.toLeader, 72, header, right: true),
                _h(strings.interval, 72, header, right: true),
                _h(strings.bestLap, 78, header, right: true),
                _h(strings.lastLap, 78, header, right: true),
                _h(strings.s1, 64, header, right: true),
                _h(strings.s2, 64, header, right: true),
                _h(strings.s3, 64, header, right: true),
                _h(strings.tyre, 36, header),
                _h(strings.lapsShort, 48, header, right: true),
                _h(strings.status, 88, header),
              ],
            ),
            const Divider(height: 8),
            for (final row in rows)
              _TimingRow(
                row: row,
                board: board,
                strings: strings,
                selected: row.driver.driverNumber == selected,
                onTap: onSelect == null ? null : () => onSelect!(row.driver.driverNumber),
              ),
          ],
        ),
      ),
    );
  }

  Widget _h(String text, double width, TextStyle style, {bool right = false}) {
    return SizedBox(
      width: width,
      child: Text(text, textAlign: right ? TextAlign.right : TextAlign.left, style: style),
    );
  }
}

class _TimingRow extends StatelessWidget {
  const _TimingRow({
    required this.row,
    required this.board,
    required this.strings,
    required this.selected,
    this.onTap,
  });

  final TimingEntry row;
  final BoardState board;
  final AppStrings strings;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(row.driver.teamColorValue);
    final style = const TextStyle(fontSize: 12, fontFeatures: [FontFeature.tabularFigures()]);
    return Material(
      color: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: selected ? color : Colors.transparent, width: 3)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _c('${row.position}', 36, style.copyWith(fontWeight: FontWeight.w800)),
              _c('${row.driver.driverNumber}', 36, style),
              _c(row.driver.nameAcronym.isEmpty ? row.driver.shortName : row.driver.nameAcronym, 150, style.copyWith(fontWeight: FontWeight.w700)),
              _c(row.driver.teamName, 130, style.copyWith(color: DashColors.muted(context))),
              _c(row.gapToLeader ?? '—', 72, style, right: true),
              _c(row.interval ?? '—', 72, style, right: true),
              _c(formatLap(row.bestLap), 78, _time(style, row.bestLap, board.fastestLap), right: true),
              _c(formatLap(row.lastLap), 78, style, right: true),
              _c(formatLap(row.sector1), 64, _time(style, row.sector1, board.fastestS1), right: true),
              _c(formatLap(row.sector2), 64, _time(style, row.sector2, board.fastestS2), right: true),
              _c(formatLap(row.sector3), 64, _time(style, row.sector3, board.fastestS3), right: true),
              SizedBox(
                width: 36,
                child: row.compound == null ? const Text('—', style: TextStyle(fontSize: 12)) : TyreChip(row.compound!),
              ),
              _c(row.laps?.toString() ?? '—', 48, style, right: true),
              _c(strings.driverStatusLabel(row.status), 88, style),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _time(TextStyle base, double? value, double? best) {
    if (value != null && best != null && (value - best).abs() < 0.0005) {
      return base.copyWith(color: AppColors.fastest, fontWeight: FontWeight.w800);
    }
    return base;
  }

  Widget _c(String text, double width, TextStyle style, {bool right = false}) {
    return SizedBox(
      width: width,
      child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: right ? TextAlign.right : TextAlign.left, style: style),
    );
  }
}

class _Cards extends StatelessWidget {
  const _Cards({
    required this.rows,
    required this.strings,
    required this.board,
    required this.selected,
    this.onSelect,
  });

  final List<TimingEntry> rows;
  final AppStrings strings;
  final BoardState board;
  final int? selected;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in rows)
          InkWell(
            onTap: onSelect == null ? null : () => onSelect!(row.driver.driverNumber),
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: row.driver.driverNumber == selected ? Color(row.driver.teamColorValue).withValues(alpha: 0.14) : DashColors.raised(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: row.driver.driverNumber == selected ? Color(row.driver.teamColorValue) : DashColors.line(context),
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 28, child: Text('${row.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.driver.shortName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        Text(
                          '${row.driver.teamName} · ${row.gapToLeader ?? '—'}',
                          style: TextStyle(color: DashColors.muted(context), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (row.compound != null) TyreChip(row.compound!),
                  const SizedBox(width: 8),
                  Text(formatLap(row.bestLap), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GridBody extends StatelessWidget {
  const _GridBody({
    required this.store,
    required this.strings,
    required this.compact,
    this.selectedDriver,
    this.onSelect,
  });

  final AppContextState store;
  final AppStrings strings;
  final bool compact;
  final int? selectedDriver;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final grid = store.latestGrid;
    if (grid.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(strings.noData));
    return Column(
      children: [
        for (final row in grid)
          InkWell(
            onTap: onSelect == null ? null : () => onSelect!(row.driverNumber),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              color: row.driverNumber == selectedDriver ? AppColors.red.withValues(alpha: 0.08) : null,
              child: Row(
                children: [
                  SizedBox(width: 36, child: Text('${row.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
                  Expanded(
                    child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}'),
                  ),
                  if (!compact)
                    Expanded(
                      child: Text(
                        store.driverByNumber(row.driverNumber)?.teamName ?? '',
                        style: TextStyle(color: DashColors.muted(context)),
                      ),
                    ),
                  Text(formatLap(row.lapDuration), style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()])),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
