import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/openf1_models.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../widgets/ui_kit.dart';
import '../bloc/app_context_cubit.dart';
import '../bloc/calendar_cubit.dart';
import '../dashboard/dashboard_screen.dart';
import '../race_details/race_details_screen.dart';
import '../widgets/async_states.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final defaultYear = context.read<AppContextCubit>().state.latestSession?.year ?? DateTime.now().year;
    return BlocProvider(
      create: (context) => CalendarCubit(context.read<OpenF1Repository>())..load(defaultYear),
      child: _CalendarView(compact: compact, defaultYear: defaultYear),
    );
  }
}

class _CalendarView extends StatelessWidget {
  const _CalendarView({required this.compact, required this.defaultYear});

  final bool compact;
  final int defaultYear;

  @override
  Widget build(BuildContext context) {
    final s = LocaleScope.stringsOf(context);
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        final year = state.year ?? defaultYear;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 16, compact ? 16 : 28, 0),
              child: ScreenTitle(title: s.calendar),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  for (final y in [2023, 2024, 2025, 2026])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$y'),
                        selected: year == y,
                        onSelected: (_) => context.read<CalendarCubit>().load(y),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: AsyncBody(
                status: state.status,
                strings: s,
                error: state.error,
                onRetry: () => context.read<CalendarCubit>().load(year),
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(compact ? 16 : 28, 8, compact ? 16 : 28, 28),
                  itemCount: state.meetings.length,
                  itemBuilder: (context, i) {
                    final meeting = state.meetings[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => RaceDetailsScreen(meeting: meeting)),
                        ),
                        child: F1Card(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(meeting.meetingName, style: const TextStyle(fontWeight: FontWeight.w800)),
                                    Text(
                                      '${meeting.countryName} · ${meeting.circuitShortName}',
                                      style: const TextStyle(color: AppColors.muted),
                                    ),
                                  ],
                                ),
                              ),
                              Text(_status(meeting, s.past, s.current, s.upcoming)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _status(Meeting m, String past, String current, String upcoming) {
    final now = DateTime.now().toUtc();
    if (m.dateEnd.isBefore(now)) return past;
    if (m.dateStart.isAfter(now)) return upcoming;
    return current;
  }
}
