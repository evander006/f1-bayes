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
        painter: _LocationPainter(
          points: points,
          colors: {
            for (final d in drivers) d.driverNumber: Color(d.teamColorValue),
          },
        ),
      ),
    );
  }
}

class _LocationPainter extends CustomPainter {
  _LocationPainter({required this.points, required this.colors});

  final List<LocationPoint> points;
  final Map<int, Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    var minX = points.first.x, maxX = points.first.x;
    var minY = points.first.y, maxY = points.first.y;
    for (final p in points) {
      if (p.x < minX) minX = p.x;
      if (p.x > maxX) maxX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.y > maxY) maxY = p.y;
    }
    final dx = (maxX - minX).abs() < 1 ? 1.0 : maxX - minX;
    final dy = (maxY - minY).abs() < 1 ? 1.0 : maxY - minY;

    Offset map(LocationPoint p) {
      final x = ((p.x - minX) / dx) * (size.width - 16) + 8;
      final y = ((p.y - minY) / dy) * (size.height - 16) + 8;
      return Offset(x, y);
    }

    final byDriver = <int, List<LocationPoint>>{};
    for (final p in points) {
      byDriver.putIfAbsent(p.driverNumber, () => []).add(p);
    }
    for (final entry in byDriver.entries) {
      final list = entry.value;
      if (list.length < 2) continue;
      final path = Path()..moveTo(map(list.first).dx, map(list.first).dy);
      for (final p in list.skip(1)) {
        path.lineTo(map(p).dx, map(p).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = (colors[entry.key] ?? AppColors.red).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    }

    final latest = <int, LocationPoint>{};
    for (final p in points) {
      latest[p.driverNumber] = p;
    }
    for (final entry in latest.entries) {
      canvas.drawCircle(
        map(entry.value),
        5,
        Paint()..color = colors[entry.key] ?? AppColors.red,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LocationPainter oldDelegate) =>
      oldDelegate.points != points;
}
