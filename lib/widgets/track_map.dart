import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/openf1_models.dart';

class TrackMap extends StatelessWidget {
  const TrackMap({
    super.key,
    required this.points,
    required this.drivers,
    this.compact = false,
  });

  final List<LocationPoint> points;
  final List<Driver> drivers;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: compact ? 1.35 : 1.5,
      child: CustomPaint(
        painter: _MonacoPainter(
          points: points,
          colors: {
            for (final d in drivers) d.driverNumber: Color(d.teamColorValue),
          },
        ),
      ),
    );
  }
}

class _MonacoPainter extends CustomPainter {
  _MonacoPainter({required this.points, required this.colors});

  final List<LocationPoint> points;
  final Map<int, Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.72)
      ..cubicTo(
        size.width * 0.08,
        size.height * 0.42,
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.42,
        size.height * 0.22,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.26,
        size.width * 0.70,
        size.height * 0.12,
        size.width * 0.84,
        size.height * 0.18,
      )
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.24,
        size.width * 0.92,
        size.height * 0.48,
        size.width * 0.78,
        size.height * 0.58,
      )
      ..cubicTo(
        size.width * 0.58,
        size.height * 0.72,
        size.width * 0.40,
        size.height * 0.88,
        size.width * 0.22,
        size.height * 0.82,
      )
      ..close();

    final track = Paint()
      ..color = const Color(0xFF1A1D24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = AppColors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, track);
    canvas.drawPath(path, accent);

    final metrics = path.computeMetrics().first;
    for (var i = 0; i < points.length; i++) {
      final t = (0.12 + i * 0.18).clamp(0.0, 0.95);
      final tangent = metrics.getTangentForOffset(metrics.length * t);
      if (tangent == null) continue;
      final color = colors[points[i].driverNumber] ?? AppColors.red;
      canvas.drawCircle(
        tangent.position,
        i == 0 ? 6 : 4.5,
        Paint()..color = color,
      );
      canvas.drawCircle(
        tangent.position,
        i == 0 ? 6 : 4.5,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MonacoPainter oldDelegate) =>
      oldDelegate.points != points;
}
