import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/models/openf1_models.dart';

class TrackMap extends StatelessWidget {
  const TrackMap({
    super.key,
    required this.points,
    required this.drivers,
    this.outline = const [],
    this.compact = false,
    this.selectedDriverNumber,
    this.onDriverSelected,
    this.showCars = true,
  });

  final List<LocationPoint> points;
  final List<LocationPoint> outline;
  final List<Driver> drivers;
  final bool compact;
  final int? selectedDriverNumber;
  final ValueChanged<int?>? onDriverSelected;
  final bool showCars;

  @override
  Widget build(BuildContext context) {
    final colors = {
      for (final d in drivers) d.driverNumber: Color(d.teamColorValue),
    };
    final acronyms = {
      for (final d in drivers) d.driverNumber: d.nameAcronym,
    };
    return AspectRatio(
      aspectRatio: compact ? 1.2 : 1.55,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          final layout = TrackLayout.from(outline: outline, points: points, size: size);
          final cars = showCars ? layout.carOffsets(points) : const <int, Offset>{};
          return GestureDetector(
            onTapDown: (details) {
              int? nearest;
              var best = 28.0;
              for (final entry in cars.entries) {
                final d = (entry.value - details.localPosition).distance;
                if (d < best) {
                  best = d;
                  nearest = entry.key;
                }
              }
              onDriverSelected?.call(nearest);
            },
            child: CustomPaint(
              painter: TrackPainter(
                layout: layout,
                cars: cars,
                colors: colors,
                acronyms: acronyms,
                selected: selectedDriverNumber,
              ),
            ),
          );
        },
      ),
    );
  }
}

class TrackLayout {
  TrackLayout({
    required this.size,
    required this.minX,
    required this.minY,
    required this.dx,
    required this.dy,
    required this.outlinePath,
    this.start,
  });

  final Size size;
  final double minX;
  final double minY;
  final double dx;
  final double dy;
  final Path outlinePath;
  final Offset? start;

  factory TrackLayout.from({
    required List<LocationPoint> outline,
    required List<LocationPoint> points,
    required Size size,
  }) {
    final source = outline.isNotEmpty ? outline : points;
    var minX = source.isEmpty ? 0.0 : source.first.x;
    var maxX = minX;
    var minY = source.isEmpty ? 0.0 : source.first.y;
    var maxY = minY;
    for (final p in [...outline, ...points]) {
      minX = math.min(minX, p.x);
      maxX = math.max(maxX, p.x);
      minY = math.min(minY, p.y);
      maxY = math.max(maxY, p.y);
    }
    final dx = (maxX - minX).abs() < 1 ? 1.0 : maxX - minX;
    final dy = (maxY - minY).abs() < 1 ? 1.0 : maxY - minY;
    Offset map(LocationPoint p) {
      final x = ((p.x - minX) / dx) * (size.width - 28) + 14;
      final y = ((maxY - p.y) / dy) * (size.height - 28) + 14;
      return Offset(x, y);
    }

    final path = Path();
    final shape = outline.isNotEmpty ? outline : points;
    if (shape.isNotEmpty) {
      path.moveTo(map(shape.first).dx, map(shape.first).dy);
      for (final p in shape.skip(1)) {
        path.lineTo(map(p).dx, map(p).dy);
      }
    }
    return TrackLayout(
      size: size,
      minX: minX,
      minY: minY,
      dx: dx,
      dy: dy,
      outlinePath: path,
      start: shape.isEmpty ? null : map(shape.first),
    );
  }

  Offset mapPoint(LocationPoint p) {
    final maxY = minY + dy;
    final x = ((p.x - minX) / dx) * (size.width - 28) + 14;
    final y = ((maxY - p.y) / dy) * (size.height - 28) + 14;
    return Offset(x, y);
  }

  Map<int, Offset> carOffsets(List<LocationPoint> points) {
    final latest = <int, LocationPoint>{};
    for (final p in points) {
      latest[p.driverNumber] = p;
    }
    return {for (final e in latest.entries) e.key: mapPoint(e.value)};
  }
}

class TrackPainter extends CustomPainter {
  TrackPainter({
    required this.layout,
    required this.cars,
    required this.colors,
    required this.acronyms,
    required this.selected,
  });

  final TrackLayout layout;
  final Map<int, Offset> cars;
  final Map<int, Color> colors;
  final Map<int, String> acronyms;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      layout.outlinePath,
      Paint()
        ..color = const Color(0xFF3A4150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.drawPath(
      layout.outlinePath,
      Paint()
        ..color = const Color(0xFFD7DCE6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final start = layout.start;
    if (start != null) {
      canvas.drawLine(
        start.translate(-7, -7),
        start.translate(7, 7),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3,
      );
    }

    for (final entry in cars.entries) {
      final highlight = selected == entry.key;
      final color = colors[entry.key] ?? AppColors.red;
      canvas.drawCircle(
        entry.value,
        highlight ? 11 : 8,
        Paint()..color = color.withValues(alpha: highlight ? 1 : 0.92),
      );
      if (highlight) {
        canvas.drawCircle(
          entry.value,
          13,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      final label = acronyms[entry.key] ?? '${entry.key}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 7,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, entry.value.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant TrackPainter oldDelegate) =>
      oldDelegate.cars != cars ||
      oldDelegate.selected != selected ||
      oldDelegate.layout.size != layout.size;
}
