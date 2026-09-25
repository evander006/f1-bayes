import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import 'load_status.dart';

class TeamDetailsState {
  const TeamDetailsState({
    this.status = LoadStatus.initial,
    this.error,
    this.pits = const [],
    this.stints = const [],
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final List<PitStop> pits;
  final List<Stint> stints;
}

class TeamDetailsCubit extends Cubit<TeamDetailsState> {
  TeamDetailsCubit(this._repo) : super(const TeamDetailsState());

  final OpenF1Repository _repo;

  Future<void> load({
    required Object sessionKey,
    required Set<int> driverNumbers,
  }) async {
    emit(const TeamDetailsState(status: LoadStatus.loading));
    try {
      final pits = (await _safe(_repo.pits(sessionKey: sessionKey)))
          .where((p) => driverNumbers.contains(p.driverNumber))
          .toList();
      final stints = (await _safe(_repo.stints(sessionKey: sessionKey)))
          .where((s) => driverNumbers.contains(s.driverNumber))
          .toList();
      emit(TeamDetailsState(
        status: pits.isEmpty && stints.isEmpty ? LoadStatus.empty : LoadStatus.success,
        pits: pits,
        stints: stints,
      ));
    } on OpenF1Exception catch (e) {
      emit(TeamDetailsState(status: LoadStatus.error, error: e));
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
