import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_openf1.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/ui_kit.dart';
import '../dashboard/dashboard_screen.dart';

class AccuracyScreen extends StatelessWidget {
  const AccuracyScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final data = MockOpenF1.snapshot;
    final a = data.accuracy;

    final table = F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.predictionVsResult),
          const SizedBox(height: 14),
          for (final race in a.byRace)
            _RaceRow(s: s, race: race),
        ],
      ),
    );

    if (compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            children: [
              Expanded(child: _MetricCard(label: s.brierScore, value: a.brierScore.toStringAsFixed(3), delta: a.brierDelta, invert: true)),
              const SizedBox(width: 12),
              Expanded(child: _MetricCard(label: s.hitRate, value: percent(a.hitRate), delta: a.hitRateDelta)),
            ],
          ),
          const SizedBox(height: 14),
          table,
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      child: Column(
        children: [
          ScreenTitle(title: '${s.accuracy} & ${s.races}'),
          const SizedBox(height: 22),
          SizedBox(
            height: 220,
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: _MetricCard(
                    label: s.brierScore,
                    value: a.brierScore.toStringAsFixed(3),
                    delta: a.brierDelta,
                    invert: true,
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 220,
                  child: _MetricCard(
                    label: s.hitRate,
                    value: percent(a.hitRate),
                    delta: a.hitRateDelta,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: _ChartCard(s: s, data: data)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: table),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    this.invert = false,
  });

  final String label;
  final String value;
  final double delta;
  final bool invert;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final good = invert ? delta < 0 : delta > 0;
    final color = good ? AppColors.hit : AppColors.miss;
    final arrow = delta < 0 ? '↓' : '↑';
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label),
          const SizedBox(height: 18),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 36)),
          const SizedBox(height: 6),
          Text(
            '$arrow ${(delta.abs() * 100).toStringAsFixed(0)}%  ${s.vsLast5}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${s.predictions} ${s.accuracy}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(s.hitRate, style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _AccuracyChartPainter(data.accuracy.byRace),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyChartPainter extends CustomPainter {
  _AccuracyChartPainter(this.races);

  final List<RaceAccuracy> races;

  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = const Color(0xFFE6E8EE);
    final linePaint = Paint()
      ..color = AppColors.red
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;
    final n = races.length;
    final path = Path();
    for (var i = 0; i < n; i++) {
      final x = size.width * (i + 0.5) / n;
      final hit = races[i].hit ? 0.78 : 0.42;
      final barH = size.height * (0.35 + (n - i) * 0.08);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 10, size.height - barH, 20, barH),
          const Radius.circular(4),
        ),
        barPaint,
      );
      final y = size.height * (1 - hit);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppColors.red);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _AccuracyChartPainter oldDelegate) => false;
}

class _RaceRow extends StatelessWidget {
  const _RaceRow({required this.s, required this.race});

  final AppStrings s;
  final RaceAccuracy race;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat(s.isRu ? 'd MMM yyyy' : 'd MMM yyyy', s.isRu ? 'ru' : 'en')
        .format(race.meeting.dateStart);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(date, style: const TextStyle(color: AppColors.muted)),
          ),
          SizedBox(
            width: 120,
            child: Text(race.meeting.countryName, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(
              '${race.predictedWinner.shortName} / ${race.actualWinner.shortName}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: race.hit ? AppColors.hit : AppColors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              race.top3Predicted.map((d) => d.nameAcronym).join(' / '),
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          Text(
            race.brierScore.toStringAsFixed(3),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
