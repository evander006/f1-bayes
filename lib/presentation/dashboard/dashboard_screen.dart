import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_openf1.dart';
import '../../domain/models/prediction_models.dart';
import '../../widgets/track_map.dart';
import '../../widgets/ui_kit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final data = MockOpenF1.snapshot;
    return compact ? _Mobile(s: s, data: data) : _Desktop(s: s, data: data);
  }
}

class _Desktop extends StatelessWidget {
  const _Desktop({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              ScreenTitle(title: s.dashboard),
              const SizedBox(height: 22),
              SizedBox(
                height: 148,
                child: Row(
                  children: [
                    Expanded(child: SizedBox.expand(child: _NextRaceCard(s: s, data: data))),
                    const SizedBox(width: 16),
                    Expanded(child: SizedBox.expand(child: _WeatherCard(s: s, data: data))),
                    const SizedBox(width: 16),
                    Expanded(child: SizedBox.expand(child: _PoleCard(s: s, data: data))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 430,
                child: Row(
                  children: [
                    Expanded(
                      flex: 11,
                      child: _TopPredictionsCard(s: s, data: data, compact: false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          Expanded(child: _AccuracyCard(s: s, data: data)),
                          const SizedBox(height: 16),
                          Expanded(flex: 2, child: _LeaderCard(s: s, data: data)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Mobile extends StatelessWidget {
  const _Mobile({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _NextRaceCard(s: s, data: data, weatherInline: true),
        const SizedBox(height: 14),
        _TopPredictionsCard(s: s, data: data, compact: true),
      ],
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        const LocaleToggle(),
        const SizedBox(width: 12),
        Icon(Icons.search_rounded, color: AppColors.muted.withValues(alpha: 0.9)),
      ],
    );
  }
}

class _NextRaceCard extends StatelessWidget {
  const _NextRaceCard({
    required this.s,
    required this.data,
    this.weatherInline = false,
  });

  final AppStrings s;
  final MockSnapshot data;
  final bool weatherInline;

  @override
  Widget build(BuildContext context) {
    final meeting = data.meeting;
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.nextRace, color: AppColors.red),
          const SizedBox(height: 10),
          Text(
            meeting.meetingName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            formatMeetingWhen(data.raceSession.dateStart, isRu: s.isRu),
            style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
          ),
          if (weatherInline) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.cloud_outlined, color: AppColors.muted),
                const SizedBox(width: 8),
                Text(
                  '${data.weather.airTemperature.toStringAsFixed(0)}°C',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
                const SizedBox(width: 12),
                Text(
                  '${s.humidity} ${data.weather.humidity.toStringAsFixed(0)}%',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    final w = data.weather;
    return F1Card(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F6FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              w.isWet ? Icons.umbrella_rounded : Icons.cloud_outlined,
              color: const Color(0xFF7B8798),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Eyebrow(s.weather),
              const SizedBox(height: 6),
              Text(
                '${w.airTemperature.toStringAsFixed(0)}°C',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                '${s.humidity} ${w.humidity.toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PoleCard extends StatelessWidget {
  const _PoleCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    final pole = data.pole;
    final driver = data.driverByNumber(pole.driverNumber);
    return F1Card(
      child: Row(
        children: [
          DriverAvatar(driver: driver, size: 54),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Eyebrow(s.currentPole),
                const SizedBox(height: 6),
                Text(
                  '#${driver.driverNumber}  ${driver.shortName}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  formatLap(pole.lapDuration),
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
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

class _TopPredictionsCard extends StatelessWidget {
  const _TopPredictionsCard({
    required this.s,
    required this.data,
    required this.compact,
  });

  final AppStrings s;
  final MockSnapshot data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final rows = data.predictions.take(5).toList();
    return F1Card(
      padding: compact ? const EdgeInsets.all(16) : const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.top5),
          const SizedBox(height: 16),
          for (var i = 0; i < rows.length; i++) ...[
            _PredictionTile(rank: i + 1, row: rows[i]),
            if (i != rows.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({required this.rank, required this.row});

  final int rank;
  final DriverPrediction row;

  @override
  Widget build(BuildContext context) {
    final color = Color(row.driver.teamColorValue);
    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            '$rank',
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted),
          ),
        ),
        DriverAvatar(driver: row.driver, size: 34),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.driver.shortName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ProbabilityBar(value: row.winProbability / 0.35, color: color),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          percent(row.winProbability),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _AccuracyCard extends StatelessWidget {
  const _AccuracyCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    final a = data.accuracy;
    return F1Card(
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: a.hitRate,
                  strokeWidth: 8,
                  backgroundColor: const Color(0xFFEEF0F4),
                  color: AppColors.red,
                ),
                Text(
                  percent(a.hitRate),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Eyebrow(s.modelAccuracy),
                const SizedBox(height: 8),
                Text('${s.brierScore}  ${a.brierScore.toStringAsFixed(3)}'),
                Text(
                  '${s.hitRate}  ${percent(a.top3Coverage)}',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderCard extends StatelessWidget {
  const _LeaderCard({required this.s, required this.data});

  final AppStrings s;
  final MockSnapshot data;

  @override
  Widget build(BuildContext context) {
    final leader = data.leader;
    return F1Card(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(s.currentLeader),
                const SizedBox(height: 10),
                Row(
                  children: [
                    DriverAvatar(driver: leader.driver, size: 48),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leader.driver.shortName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'P${leader.position.position}  ·  ${leader.driver.teamName}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  '${data.meeting.circuitShortName}  ${data.circuitLengthKm} km  ·  ${data.totalLaps} ${s.lap.toLowerCase()}s',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 180,
            child: TrackMap(
              points: data.trackLocations,
              drivers: data.drivers,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}
