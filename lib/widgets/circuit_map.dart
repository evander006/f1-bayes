import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../data/circuits/circuit_layouts.dart';
import '../data/models/openf1_models.dart';

class CarPlot {
  const CarPlot({
    required this.driverNumber,
    required this.x,
    required this.y,
    required this.color,
    required this.label,
    required this.name,
  });

  final int driverNumber;
  final double x;
  final double y;
  final Color color;
  final String label;
  final String name;
}

class CircuitMap extends StatefulWidget {
  const CircuitMap({
    super.key,
    this.trace = const [],
    this.schematic,
    this.cars = const [],
    this.selectedDriver,
    this.onSelect,
    this.animateCars = false,
    this.sectorOrigin,
    this.sector1,
    this.sector2,
  });

  final List<LocationPoint> trace;
  final CircuitLayout? schematic;
  final List<CarPlot> cars;
  final int? selectedDriver;
  final ValueChanged<int>? onSelect;
  final bool animateCars;
  final DateTime? sectorOrigin;
  final double? sector1;
  final double? sector2;

  @override
  State<CircuitMap> createState() => _CircuitMapState();
}

class _CircuitMapState extends State<CircuitMap> {
  bool _placed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _placed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final projection = projectCircuit(
          size: size,
          trace: widget.trace,
          schematic: widget.schematic,
          cars: widget.cars,
          sectorOrigin: widget.sectorOrigin,
          sector1: widget.sector1,
          sector2: widget.sector2,
        );
        if (projection.outline.length < 2) {
          return const SizedBox.expand();
        }
        final duration = !_placed || !widget.animateCars || reduce
            ? Duration.zero
            : const Duration(milliseconds: 650);
        return Stack(
          children: [
            CustomPaint(
              size: size,
              painter: _CircuitPainter(projection),
            ),
            for (final car in projection.cars)
              AnimatedPositioned(
                duration: duration,
                curve: Curves.easeOutCubic,
                left: car.offset.dx - (car.car.driverNumber == widget.selectedDriver ? 13 : 11),
                top: car.offset.dy - (car.car.driverNumber == widget.selectedDriver ? 13 : 11),
                child: _DriverMarker(
                  car: car.car,
                  selected: car.car.driverNumber == widget.selectedDriver,
                  onTap: widget.onSelect == null ? null : () => widget.onSelect!(car.car.driverNumber),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _DriverMarker extends StatelessWidget {
  const _DriverMarker({required this.car, required this.selected, this.onTap});

  final CarPlot car;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 26.0 : 22.0;
    final ink = car.color.computeLuminance() > 0.62 ? const Color(0xFF12141A) : Colors.white;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: car.name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: car.color,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? Colors.white : const Color(0xFF07080B), width: selected ? 2 : 1.4),
              boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 4)],
            ),
            child: Text(
              car.label,
              style: TextStyle(color: ink, fontSize: 8, fontWeight: FontWeight.w800, height: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class ProjectedCar {
  const ProjectedCar({required this.car, required this.offset});

  final CarPlot car;
  final Offset offset;
}

class CircuitProjection {
  const CircuitProjection({
    required this.outline,
    required this.segmentColors,
    required this.cars,
    required this.start,
    required this.startHeading,
  });

  final List<Offset> outline;
  final List<Color?> segmentColors;
  final List<ProjectedCar> cars;
  final Offset? start;
  final Offset? startHeading;
}

CircuitProjection projectCircuit({
  required Size size,
  required List<LocationPoint> trace,
  required CircuitLayout? schematic,
  required List<CarPlot> cars,
  DateTime? sectorOrigin,
  double? sector1,
  double? sector2,
}) {
  final useTrace = trace.length >= 2;
  if (!useTrace && (schematic == null || schematic.points.length < 2)) {
    return const CircuitProjection(
      outline: [],
      segmentColors: [],
      cars: [],
      start: null,
      startHeading: null,
    );
  }

  final raw = useTrace
      ? [for (final point in trace) Offset(point.x, point.y)]
      : schematic!.points;
  var minX = raw.first.dx;
  var maxX = raw.first.dx;
  var minY = raw.first.dy;
  var maxY = raw.first.dy;
  for (final point in raw) {
    if (point.dx < minX) minX = point.dx;
    if (point.dx > maxX) maxX = point.dx;
    if (point.dy < minY) minY = point.dy;
    if (point.dy > maxY) maxY = point.dy;
  }
  final spanX = (maxX - minX).abs() < 1e-6 ? 1.0 : maxX - minX;
  final spanY = (maxY - minY).abs() < 1e-6 ? 1.0 : maxY - minY;
  const pad = 36.0;
  final innerW = (size.width - pad).clamp(1.0, size.width);
  final innerH = (size.height - pad).clamp(1.0, size.height);
  final scale = (innerW / spanX) < (innerH / spanY) ? innerW / spanX : innerH / spanY;
  final drawnW = spanX * scale;
  final drawnH = spanY * scale;
  final originX = (size.width - drawnW) / 2;
  final originY = (size.height - drawnH) / 2;

  Offset map(double x, double y) {
    final sx = originX + (x - minX) * scale;
    final sy = useTrace ? originY + (maxY - y) * scale : originY + (y - minY) * scale;
    return Offset(sx, sy);
  }

  final outline = [for (final point in raw) map(point.dx, point.dy)];
  final colors = <Color?>[];
  if (useTrace && sectorOrigin != null && sector1 != null && sector2 != null) {
    for (final point in trace) {
      final seconds = point.date.toUtc().difference(sectorOrigin.toUtc()).inMicroseconds / 1e6;
      if (seconds < sector1) {
        colors.add(const Color(0xFFE10600));
      } else if (seconds < sector1 + sector2) {
        colors.add(const Color(0xFFF5C518));
      } else {
        colors.add(const Color(0xFF7DD3C7));
      }
    }
  } else {
    colors.addAll(List<Color?>.filled(outline.length, null));
  }

  final slackX = spanX * 0.12;
  final slackY = spanY * 0.12;
  final projectedCars = <ProjectedCar>[];
  if (useTrace) {
    for (final car in cars) {
      final inside = car.x >= minX - slackX &&
          car.x <= maxX + slackX &&
          car.y >= minY - slackY &&
          car.y <= maxY + slackY;
      if (!inside) continue;
      projectedCars.add(ProjectedCar(car: car, offset: map(car.x, car.y)));
    }
  }

  Offset? heading;
  if (outline.length >= 2) {
    heading = outline[1] - outline[0];
  }

  return CircuitProjection(
    outline: outline,
    segmentColors: colors,
    cars: projectedCars,
    start: outline.isEmpty ? null : outline.first,
    startHeading: heading,
  );
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.projection);

  final CircuitProjection projection;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = projection.outline;
    if (outline.length < 2) return;
    final base = Paint()
      ..color = const Color(0xFF3A414C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()..moveTo(outline.first.dx, outline.first.dy);
    for (final point in outline.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    final closing = (outline.first - outline.last).distance;
    if (closing < 28) path.close();
    canvas.drawPath(path, base);

    final colored = projection.segmentColors.any((color) => color != null);
    if (!colored) {
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFE6E8EE)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    } else {
      for (var i = 1; i < outline.length; i++) {
        final color = projection.segmentColors[i] ?? const Color(0xFFE6E8EE);
        canvas.drawLine(
          outline[i - 1],
          outline[i],
          Paint()
            ..color = color
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    final start = projection.start;
    final heading = projection.startHeading;
    if (start != null && heading != null && heading.distance > 0.001) {
      final tangent = heading / heading.distance;
      final normal = Offset(-tangent.dy, tangent.dx);
      final a = start - normal * 10;
      final b = start + normal * 10;
      canvas.drawLine(a, b, Paint()..color = Colors.white..strokeWidth = 3);
      canvas.drawLine(
        a,
        start,
        Paint()
          ..color = AppColors.red
          ..strokeWidth = 3,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) =>
      oldDelegate.projection.outline != projection.outline ||
      oldDelegate.projection.segmentColors.length != projection.segmentColors.length;
}
