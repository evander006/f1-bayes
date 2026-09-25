import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/load_status.dart';
import '../bloc/telemetry_cubit.dart';
import '../widgets/async_states.dart';

class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TelemetryCubit(context.read<OpenF1Repository>()),
      child: const _TelemetryView(),
    );
  }
}

class _TelemetryView extends StatelessWidget {
  const _TelemetryView();

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final app = context.watch<AppContextCubit>().state;
    return Scaffold(
      appBar: AppBar(title: Text(s.telemetry)),
      body: BlocBuilder<TelemetryCubit, TelemetryState>(
        builder: (context, state) {
          final latest = state.points.isEmpty ? null : state.points.last;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final driver in app.drivers.take(12))
                    ChoiceChip(
                      label: Text(driver.nameAcronym),
                      selected: state.driverNumber == driver.driverNumber,
                      onSelected: (_) {
                        final session = app.latestSession;
                        if (session == null) return;
                        context.read<TelemetryCubit>().load(
                              sessionKey: session.sessionKey,
                              driverNumber: driver.driverNumber,
                              sessionEnd: session.dateEnd,
                            );
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.status == LoadStatus.loading) const LinearProgressIndicator(),
              if (state.status == LoadStatus.error)
                F1Card(child: Text(errorText(s, state.error))),
              if (state.status == LoadStatus.empty) F1Card(child: Text(s.noData)),
              if (latest != null) ...[
                F1Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${s.speed}: ${latest.speed ?? '—'}'),
                      Text('${s.throttle}: ${latest.throttle ?? '—'}'),
                      Text('${s.brake}: ${latest.brake ?? '—'}'),
                      Text('${s.rpm}: ${latest.rpm ?? '—'}'),
                      Text('${s.gear}: ${latest.nGear ?? '—'}'),
                      Text('${s.drs}: ${latest.drs ?? '—'}'),
                      Text(latest.date.toLocal().toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                F1Card(
                  child: SizedBox(
                    height: 160,
                    child: CustomPaint(
                      painter: _SpeedChart(state.points),
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SpeedChart extends CustomPainter {
  _SpeedChart(this.points);
  final List<CarData> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final ys = points.map((p) => (p.speed ?? 0).toDouble()).toList();
    final maxY = ys.reduce((a, b) => a > b ? a : b);
    final minY = ys.reduce((a, b) => a < b ? a : b);
    final span = (maxY - minY).abs() < 1 ? 1.0 : maxY - minY;
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final x = size.width * i / (points.length - 1).clamp(1, 1 << 20);
      final y = size.height - ((ys[i] - minY) / span) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.red
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _SpeedChart oldDelegate) => oldDelegate.points != points;
}
