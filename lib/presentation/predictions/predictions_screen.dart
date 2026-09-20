import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_openf1.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/ui_kit.dart';
import '../dashboard/dashboard_screen.dart';
import '../driver_detail/driver_detail_screen.dart';

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key, this.compact = false});

  final bool compact;

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  bool leaderDnf = false;
  int selectedIndex = 0;

  List<DriverPrediction> _rows(MockSnapshot data) {
    final source = data.predictions;
    if (!leaderDnf) return source;
    final leaderNum = data.leader.driver.driverNumber;
    final without = source.where((p) => p.driver.driverNumber != leaderNum).toList();
    final total = without.fold<double>(0, (a, b) => a + b.winProbability);
    return [
      for (final p in without)
        DriverPrediction(
          driver: p.driver,
          winProbability: p.winProbability / total,
          grid: p.grid,
          features: p.features,
          qualifying: p.qualifying,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final data = MockOpenF1.snapshot;
    final rows = _rows(data);
    final selected = rows[selectedIndex.clamp(0, rows.length - 1)];

    if (widget.compact) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          F1Card(
            child: Column(
              children: [
                for (var i = 0; i < rows.take(5).length; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == 4 ? 0 : 10),
                    child: _DriverProbRow(
                      rank: i + 1,
                      row: rows[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DriverDetailScreen(prediction: rows[i]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _FeatureCard(s: s, selected: selected),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
      child: Column(
        children: [
          ScreenTitle(title: s.predictions),
          const SizedBox(height: 22),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: F1Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(s.winProbability),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            SizedBox(width: 28, child: Text('#', style: _head)),
                            Expanded(child: Text('Driver', style: _head)),
                            Text('Probability', style: _head),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            itemCount: rows.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 4),
                            itemBuilder: (context, i) {
                              return _DriverProbRow(
                                rank: i + 1,
                                row: rows[i],
                                selected: i == selectedIndex,
                                onTap: () => setState(() => selectedIndex = i),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Expanded(child: _FeatureCard(s: s, selected: selected)),
                      const SizedBox(height: 16),
                      F1Card(
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.leaderDnf,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s.leaderDnfHint,
                                    style: const TextStyle(color: AppColors.muted, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: leaderDnf,
                              onChanged: (v) => setState(() {
                                leaderDnf = v;
                                selectedIndex = 0;
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1A1D24), Color(0xFF7A1020), Color(0xFFE10600)],
                            ),
                          ),
                        ),
                        Positioned(
                          right: -30,
                          bottom: -20,
                          child: Icon(
                            Icons.speed_rounded,
                            size: 180,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              s.heroTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 28,
                                height: 1.15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _head = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.muted,
);

class _DriverProbRow extends StatelessWidget {
  const _DriverProbRow({
    required this.rank,
    required this.row,
    this.selected = false,
    this.onTap,
  });

  final int rank;
  final DriverPrediction row;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(row.driver.teamColorValue);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F8FB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text('$rank', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted)),
            ),
            DriverAvatar(driver: row.driver, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.driver.shortName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ProbabilityBar(value: row.winProbability / 0.4, color: color),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(percent(row.winProbability), style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.s, required this.selected});

  final AppStrings s;
  final DriverPrediction selected;

  @override
  Widget build(BuildContext context) {
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.featureContribution),
          const SizedBox(height: 8),
          Text(
            selected.driver.shortName,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 16),
          for (final f in selected.features) ...[
            Row(
              children: [
                SizedBox(
                  width: 130,
                  child: Text(s.featureLabel(f.id), style: const TextStyle(fontSize: 13)),
                ),
                Expanded(
                  child: ProbabilityBar(
                    value: f.weight,
                    color: Color(selected.driver.teamColorValue),
                    height: 10,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(f.weight * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
