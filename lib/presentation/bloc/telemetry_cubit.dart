import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import 'load_status.dart';

class TelemetryState {
  const TelemetryState({
    this.status = LoadStatus.initial,
    this.error,
    this.driverNumber,
    this.points = const [],
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final int? driverNumber;
  final List<CarData> points;
}

class TelemetryCubit extends Cubit<TelemetryState> {
  TelemetryCubit(this._repo) : super(const TelemetryState());

  final OpenF1Repository _repo;
  bool _inFlight = false;

  Future<void> load({
    required Object sessionKey,
    required int driverNumber,
    required DateTime sessionEnd,
  }) async {
    if (_inFlight || isClosed) return;
    _inFlight = true;
    emit(TelemetryState(status: LoadStatus.loading, driverNumber: driverNumber));
    try {
      // The API's `date>` filter is relative to the beginning of the query,
      // so use the end of the session only to select the latest data window.
      // The previous implementation queried `sessionEnd - 2 min`, which could
      // return only a tiny tail or no data at all for older sessions.
      final end = sessionEnd.isBefore(DateTime.now().toUtc())
          ? sessionEnd.toUtc()
          : DateTime.now().toUtc();
      final start = end.subtract(const Duration(minutes: 2));
      final data = await _repo.carData(
        sessionKey: sessionKey,
        driverNumber: driverNumber,
        dateGt: start.toIso8601String(),
      );
      final clipped = data.length > 200 ? data.sublist(data.length - 200) : data;
      emit(TelemetryState(
        status: clipped.isEmpty ? LoadStatus.empty : LoadStatus.success,
        driverNumber: driverNumber,
        points: clipped,
      ));
    } on OpenF1Exception catch (e) {
      emit(TelemetryState(status: LoadStatus.error, error: e, driverNumber: driverNumber));
    } finally {
      _inFlight = false;
    }
  }
}
