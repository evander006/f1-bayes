import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/ui_kit.dart';

class LiveTimingTable extends StatelessWidget {
  const LiveTimingTable({
    super.key,
    required this.strings,
    required this.rows,
    required this.sessionLabel,
    this.selectedDriverNumber,
    this.onDriverSelected,
    this.compact = false,
  });

  final AppStrings strings;
  final List<LiveClassificationRow> rows;
  final String sessionLabel;
  final int? selectedDriverNumber;
  final ValueChanged<int>? onDriverSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Eyebrow(strings.classification, color: AppColors.red),
              const Spacer(),
              if (sessionLabel.isNotEmpty)
                Text(
                  sessionLabel,
                  style: const TextStyle(color: AppColors.mutedDark, fontSize: 11, fontWeight: FontWeight.w600),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (rows.isEmpty) Text(strings.noData),
          if (rows.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: compact ? 520 : 640),
                  child: Column(
                    children: [
                      _header(),
                      for (final row in rows) _row(context, row),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          _cell(strings.pos, 28, muted: true),
          const SizedBox(width: 36),
          Expanded(child: _text(strings.driver, muted: true)),
          _cell(strings.toAhead, 68, muted: true, align: TextAlign.right),
          _cell(strings.toLeader, 68, muted: true, align: TextAlign.right),
          _cell(strings.lastLap, 72, muted: true, align: TextAlign.right),
          _cell(strings.sector1, 52, muted: true, align: TextAlign.right),
          _cell(strings.sector2, 52, muted: true, align: TextAlign.right),
          _cell(strings.sector3, 52, muted: true, align: TextAlign.right),
          _cell(strings.tyre, 36, muted: true, align: TextAlign.center),
          _cell(strings.lap, 36, muted: true, align: TextAlign.right),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, LiveClassificationRow row) {
    final selected = selectedDriverNumber == row.driver.driverNumber;
    final team = Color(row.driver.teamColorValue);
    final last = row.bestLap;
    return Material(
      color: selected ? AppColors.red.withValues(alpha: 0.12) : Colors.transparent,
      child: InkWell(
        onTap: () => onDriverSelected?.call(row.driver.driverNumber),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              _cell('${row.position}', 28, bold: true),
              Container(
                width: 3,
                height: 22,
                margin: const EdgeInsets.only(right: 8),
                color: team,
              ),
              SizedBox(
                width: 25,
                child: Text(
                  '${row.driver.driverNumber}',
                  style: const TextStyle(fontSize: 11, color: AppColors.mutedDark, fontWeight: FontWeight.w700),
                ),
              ),
              Expanded(
                child: Text(
                  row.driver.nameAcronym.isEmpty ? row.driver.shortName : row.driver.nameAcronym,
                  style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4),
                ),
              ),
              _cell(_ahead(row), 68, align: TextAlign.right, tabular: true),
              _cell(_leader(row), 68, align: TextAlign.right, tabular: true),
              _cell(formatLap(last?.lapDuration), 72, align: TextAlign.right, tabular: true),
              _cell(last?.durationSector1?.toStringAsFixed(3) ?? '—', 52, align: TextAlign.right, tabular: true),
              _cell(last?.durationSector2?.toStringAsFixed(3) ?? '—', 52, align: TextAlign.right, tabular: true),
              _cell(last?.durationSector3?.toStringAsFixed(3) ?? '—', 52, align: TextAlign.right, tabular: true),
              SizedBox(
                width: 36,
                child: row.stint?.compound == null
                    ? const SizedBox.shrink()
                    : Center(child: TyreChip(row.stint!.compound!)),
              ),
              _cell(last?.lapNumber.toString() ?? '—', 36, align: TextAlign.right, tabular: true),
            ],
          ),
        ),
      ),
    );
  }

  String _leader(LiveClassificationRow row) =>
      row.interval?.gapToLeaderLabel ?? (row.position == 1 ? 'LEADER' : '—');

  String _ahead(LiveClassificationRow row) =>
      row.interval?.intervalLabel ?? (row.position == 1 ? 'LEADER' : '—');

  Widget _cell(
    String text,
    double width, {
    bool muted = false,
    bool bold = false,
    bool tabular = false,
    TextAlign align = TextAlign.left,
  }) {
    return SizedBox(
      width: width,
      child: _text(text, muted: muted, bold: bold, tabular: tabular, align: align),
    );
  }

  Widget _text(
    String text, {
    bool muted = false,
    bool bold = false,
    bool tabular = false,
    TextAlign align = TextAlign.left,
  }) {
    return Text(
      text,
      textAlign: align,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
        color: muted ? AppColors.mutedDark : null,
        fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
      ),
    );
  }
}
