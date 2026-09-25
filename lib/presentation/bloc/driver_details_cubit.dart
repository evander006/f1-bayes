import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import 'load_status.dart';

class DriverDetailsState {
  const DriverDetailsState({
    this.status = LoadStatus.initial,
    this.error,
    this.laps = const [],
    this.pits = const [],
    this.stints = const [],
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final List<Lap> laps;
  final List<PitStop> pits;
  final List<Stint> stints;
}

class DriverDetailsCubit extends Cubit<DriverDetailsState> {
  DriverDetailsCubit(this._repo) : super(const DriverDetailsState());

  final OpenF1Repository _repo;

  Future<void> load({required Object sessionKey, required int driverNumber}) async {
    emit(const DriverDetailsState(status: LoadStatus.loading));
    try {
      final laps = await _safe(_repo.laps(sessionKey: sessionKey, driverNumber: driverNumber));
      final pits = await _safe(_repo.pits(sessionKey: sessionKey, driverNumber: driverNumber));
      final stints = await _safe(_repo.stints(sessionKey: sessionKey, driverNumber: driverNumber));
      final empty = laps.isEmpty && pits.isEmpty && stints.isEmpty;
      emit(DriverDetailsState(
        status: empty ? LoadStatus.empty : LoadStatus.success,
        laps: laps,
        pits: pits,
        stints: stints,
      ));
    } on OpenF1Exception catch (e) {
      emit(DriverDetailsState(status: LoadStatus.error, error: e));
    }
  }

  Future<List<T>> _safe<T>(Future<List<T>> future) async {
    try {
      return await future;
    } catch (_) {
      return <T>[];
    }
  }
}
