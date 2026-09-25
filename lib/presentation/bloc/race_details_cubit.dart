import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import 'load_status.dart';

class RaceDetailsState {
  const RaceDetailsState({
    this.status = LoadStatus.initial,
    this.error,
    this.sessions = const [],
    this.selected,
    this.results = const [],
    this.grid = const [],
    this.pits = const [],
    this.overtakes = const [],
    this.control = const [],
    this.radio = const [],
    this.weather = const [],
    this.stints = const [],
    this.laps = const [],
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final List<Session> sessions;
  final Session? selected;
  final List<SessionResult> results;
  final List<StartingGrid> grid;
  final List<PitStop> pits;
  final List<Overtake> overtakes;
  final List<RaceControlEvent> control;
  final List<TeamRadio> radio;
  final List<Weather> weather;
  final List<Stint> stints;
  final List<Lap> laps;
}

class RaceDetailsCubit extends Cubit<RaceDetailsState> {
  RaceDetailsCubit(this._repo) : super(const RaceDetailsState());

  final OpenF1Repository _repo;

  Future<void> load(Meeting meeting) async {
    emit(const RaceDetailsState(status: LoadStatus.loading));
    try {
      final sessions = await _repo.sessions(meetingKey: meeting.meetingKey);
      sessions.sort((a, b) => a.dateStart.compareTo(b.dateStart));
      final race = sessions.where((s) => s.isRace).toList();
      final selected = race.isNotEmpty
          ? race.last
          : (sessions.isNotEmpty ? sessions.last : null);
      if (selected == null) {
        emit(RaceDetailsState(status: LoadStatus.empty, sessions: sessions));
        return;
      }
      await selectSession(selected, sessions: sessions);
    } on OpenF1Exception catch (e) {
      emit(RaceDetailsState(status: LoadStatus.error, error: e));
    }
  }

  Future<void> selectSession(Session session, {List<Session>? sessions}) async {
    emit(RaceDetailsState(
      status: LoadStatus.loading,
      sessions: sessions ?? state.sessions,
      selected: session,
    ));
    try {
      final results = await _safe(_repo.sessionResults(sessionKey: session.sessionKey));
      final grid = await _safe(_repo.startingGrid(sessionKey: session.sessionKey));
      final pits = await _safe(_repo.pits(sessionKey: session.sessionKey));
      final overtakes = await _safe(_repo.overtakes(sessionKey: session.sessionKey));
      final control = await _safe(_repo.raceControl(sessionKey: session.sessionKey));
      final radio = await _safe(_repo.teamRadio(sessionKey: session.sessionKey));
      final weather = await _safe(_repo.weather(sessionKey: session.sessionKey));
      final stints = await _safe(_repo.stints(sessionKey: session.sessionKey));
      final empty = results.isEmpty &&
          grid.isEmpty &&
          pits.isEmpty &&
          weather.isEmpty &&
          control.isEmpty;
      emit(RaceDetailsState(
        status: empty ? LoadStatus.empty : LoadStatus.success,
        sessions: sessions ?? state.sessions,
        selected: session,
        results: results,
        grid: grid,
        pits: pits,
        overtakes: overtakes,
        control: control,
        radio: radio,
        weather: weather,
        stints: stints,
      ));
    } on OpenF1Exception catch (e) {
      emit(RaceDetailsState(
        status: LoadStatus.error,
        error: e,
        sessions: sessions ?? state.sessions,
        selected: session,
      ));
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
