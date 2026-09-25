import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import 'load_status.dart';

class CalendarState {
  const CalendarState({
    this.status = LoadStatus.initial,
    this.error,
    this.year,
    this.meetings = const [],
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final int? year;
  final List<Meeting> meetings;
}

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(this._repo) : super(const CalendarState());

  final OpenF1Repository _repo;

  Future<void> load(int year) async {
    emit(CalendarState(status: LoadStatus.loading, year: year));
    try {
      final meetings = await _repo.meetings(year: year);
      meetings.sort((a, b) => a.dateStart.compareTo(b.dateStart));
      emit(CalendarState(
        status: meetings.isEmpty ? LoadStatus.empty : LoadStatus.success,
        year: year,
        meetings: meetings,
      ));
    } on OpenF1Exception catch (e) {
      emit(CalendarState(status: LoadStatus.error, error: e, year: year));
    }
  }
}
