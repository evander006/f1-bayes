import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/race_details_cubit.dart';
import '../widgets/async_states.dart';

class RaceDetailsScreen extends StatelessWidget {
  const RaceDetailsScreen({super.key, required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RaceDetailsCubit(context.read<OpenF1Repository>())..load(meeting),
      child: _RaceDetailsView(meeting: meeting),
    );
  }
}

class _RaceDetailsView extends StatelessWidget {
  const _RaceDetailsView({required this.meeting});

  final Meeting meeting;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    final drivers = context.read<AppContextCubit>().state;
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        appBar: AppBar(
          title: Text(meeting.meetingName),
          bottom: TabBar(
            isScrollable: true,
            labelColor: AppColors.red,
            tabs: [
              Tab(text: s.sessions),
              Tab(text: s.results),
              Tab(text: s.grid),
              Tab(text: s.weather),
              Tab(text: s.pits),
              Tab(text: s.overtakes),
              Tab(text: s.raceControl),
              Tab(text: s.radio),
            ],
          ),
        ),
        body: BlocBuilder<RaceDetailsCubit, RaceDetailsState>(
          builder: (context, state) {
            return AsyncBody(
              status: state.status,
              strings: s,
              error: state.error,
              onRetry: () => context.read<RaceDetailsCubit>().load(meeting),
              child: TabBarView(
                children: [
                  ListView(
                    children: [
                      for (final session in state.sessions)
                        ListTile(
                          title: Text(session.sessionName),
                          subtitle: Text(formatMeetingWhen(session.dateStart, isRu: s.isRu)),
                          selected: state.selected?.sessionKey == session.sessionKey,
                          onTap: () => context.read<RaceDetailsCubit>().selectSession(session),
                        ),
                    ],
                  ),
                  _orEmpty(s, state.results, (row) => ListTile(
                    leading: Text('${row.position}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    title: Text(drivers.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}'),
                    subtitle: Text(row.dnf ? 'DNF' : (row.gapToLeader ?? (row.position == 1 ? 'LEADER' : '—'))),
                  )),
                  _orEmpty(s, state.grid, (row) => ListTile(
                    leading: Text('P${row.position}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    title: Text(drivers.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}'),
                    trailing: Text(formatLap(row.lapDuration)),
                  )),
                  state.weather.isEmpty
                      ? Center(child: Text(s.noData))
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            F1Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${s.airTemp}: ${state.weather.last.airTemperature ?? '—'}'),
                                  Text('${s.trackTemp}: ${state.weather.last.trackTemperature ?? '—'}'),
                                  Text('${s.humidity}: ${state.weather.last.humidity ?? '—'}'),
                                  Text('${s.pressure}: ${state.weather.last.pressure ?? '—'}'),
                                  Text('${s.wind}: ${state.weather.last.windSpeed ?? '—'}'),
                                  Text('${s.rainfall}: ${state.weather.last.rainfall ?? '—'}'),
                                  Text('${s.stints}: ${state.stints.length}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _orEmpty(s, state.pits, (row) => ListTile(
                    title: Text(drivers.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}'),
                    subtitle: Text('${s.lap} ${row.lapNumber}'),
                    trailing: Text(row.pitDuration == null ? '—' : '${row.pitDuration}s'),
                  )),
                  _orEmpty(s, state.overtakes, (row) => ListTile(
                    title: Text(
                      '${drivers.driverByNumber(row.overtakingDriverNumber)?.nameAcronym ?? row.overtakingDriverNumber} → ${drivers.driverByNumber(row.overtakenDriverNumber)?.nameAcronym ?? row.overtakenDriverNumber}',
                    ),
                    subtitle: Text(row.date.toLocal().toString()),
                  )),
                  _orEmpty(s, state.control, (row) => ListTile(
                    leading: Text(row.flag ?? '•', style: const TextStyle(fontWeight: FontWeight.w800)),
                    title: Text(row.message ?? '—'),
                    subtitle: Text('${row.date.toLocal()} · ${s.lap} ${row.lapNumber ?? '—'}'),
                  )),
                  _orEmpty(s, state.radio, (row) => ListTile(
                    title: Text(drivers.driverByNumber(row.driverNumber)?.shortName ?? '#${row.driverNumber}'),
                    subtitle: Text(row.recordingUrl ?? s.noAudio),
                  )),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _orEmpty<T>(AppStrings s, List<T> items, Widget Function(T) builder) {
    if (items.isEmpty) return Center(child: Text(s.noData));
    return ListView(children: [for (final item in items) builder(item)]);
  }
}
