import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../race_details/race_details_screen.dart';
import '../search/search_screen.dart';
import '../widgets/async_states.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<AppContextCubit, AppContextState>(
      builder: (context, store) {
        return AsyncBody(
      status: store.status,
      strings: s,
      error: store.error,
      onRetry: context.read<AppContextCubit>().load,
      child: ListView(
        padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 28),
        children: [
          ScreenTitle(
            title: s.dashboard,
            onSearch: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
          ),
          const SizedBox(height: 18),
          if (!compact)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _EventCard(s: s, store: store)),
                const SizedBox(width: 16),
                Expanded(child: _WeatherCard(s: s, store: store)),
                const SizedBox(width: 16),
                Expanded(child: _StandingsCard(s: s, store: store)),
              ],
            )
          else ...[
            _EventCard(s: s, store: store),
            const SizedBox(height: 12),
            _WeatherCard(s: s, store: store),
          ],
          const SizedBox(height: 16),
          _PredictionsCard(s: s, store: store),
          const SizedBox(height: 16),
          _ResultsCard(s: s, store: store),
        ],
      ),
    );
      },
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle({super.key, required this.title, this.onSearch});

  final String title;
  final VoidCallback? onSearch;

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
        if (onSearch != null) ...[
          const SizedBox(width: 12),
          IconButton(onPressed: onSearch, icon: const Icon(Icons.search_rounded)),
        ],
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.s, required this.store});

  final AppStrings s;
  final AppContextState store;

  @override
  Widget build(BuildContext context) {
    final meeting = store.nextMeeting ?? store.currentMeeting;
    final session = store.latestSession;
    if (meeting == null) return F1Card(child: Text(s.noData));
    final start = session?.dateStart ?? meeting.dateStart;
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RaceDetailsScreen(meeting: meeting)),
      ),
      child: F1Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(s.nextRace, color: AppColors.red),
            const SizedBox(height: 8),
            Text(meeting.meetingName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              '${meeting.location} · ${session?.sessionName ?? meeting.circuitShortName}',
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 6),
            Text(
              formatMeetingWhen(start, isRu: s.isRu),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (store.countdown != null)
              Text(
                _countdown(store.countdown!),
                style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w800),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard({required this.s, required this.store});

  final AppStrings s;
  final AppContextState store;

  @override
  Widget build(BuildContext context) {
    final w = store.weather;
    if (w == null) {
      return F1Card(child: Text(s.noData));
    }
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.weather),
          const SizedBox(height: 10),
          Text(
            w.airTemperature == null ? '—' : '${w.airTemperature!.toStringAsFixed(0)}°C',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 32),
          ),
          Text('${s.humidity} ${w.humidity?.toStringAsFixed(0) ?? '—'}%'),
          Text('${s.trackTemp} ${w.trackTemperature?.toStringAsFixed(0) ?? '—'}°C'),
        ],
      ),
    );
  }
}

class _StandingsCard extends StatelessWidget {
  const _StandingsCard({required this.s, required this.store});

  final AppStrings s;
  final AppContextState store;

  @override
  Widget build(BuildContext context) {
    final top = store.driverStandings.take(5).toList();
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.championship),
          const SizedBox(height: 10),
          if (top.isEmpty) Text(s.noData),
          for (final row in top)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text('${row.positionCurrent ?? '—'}', style: const TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(store.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}')),
                  Text(row.pointsCurrent?.toStringAsFixed(0) ?? '—'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PredictionsCard extends StatelessWidget {
  const _PredictionsCard({required this.s, required this.store});

  final AppStrings s;
  final AppContextState store;

  @override
  Widget build(BuildContext context) {
    final rows = store.predictions.take(5).toList();
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(s.top5),
          const SizedBox(height: 12),
          if (rows.isEmpty) Text(s.noData),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(width: 20, child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted))),
                  DriverAvatar(driver: rows[i].driver),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].driver.shortName, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ProbabilityBar(value: rows[i].winProbability / 0.4, color: Color(rows[i].driver.teamColorValue)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(percent(rows[i].winProbability), style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ResultsCard extends StatelessWidget {
  const _ResultsCard({required this.s, required this.store});

  final AppStrings s;
  final AppContextState store;

  @override
  Widget build(BuildContext context) {
    final results = store.latestResults.take(8).toList();
    return F1Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow('${s.results} · ${store.latestSession?.sessionName ?? ''}'),
          const SizedBox(height: 12),
          if (results.isEmpty) Text(s.noData),
          for (final row in results)
            _ResultLine(store: store, result: row),
        ],
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.store, required this.result});

  final AppContextState store;
  final SessionResult result;

  @override
  Widget build(BuildContext context) {
    final driver = store.driverByNumber(result.driverNumber);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('${result.position}', style: const TextStyle(fontWeight: FontWeight.w800))),
          if (driver != null) DriverAvatar(driver: driver, size: 28),
          const SizedBox(width: 8),
          Expanded(child: Text(driver?.shortName ?? '#${result.driverNumber}')),
          Text(result.gapToLeader ?? (result.position == 1 ? 'LEADER' : '—')),
        ],
      ),
    );
  }
}

String _countdown(Duration d) {
  final days = d.inDays;
  final hours = d.inHours % 24;
  final mins = d.inMinutes % 60;
  if (days > 0) return '${days}d ${hours}h';
  return '${hours}h ${mins}m';
}
