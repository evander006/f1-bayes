import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../domain/bayes/naive_bayes_predictor.dart';
import '../../domain/models/prediction_models.dart';
import 'load_status.dart';

class AppContextState {
  const AppContextState({
    this.status = LoadStatus.initial,
    this.error,
    this.latestSession,
    this.currentMeeting,
    this.nextMeeting,
    this.meetings = const [],
    this.currentSessions = const [],
    this.drivers = const [],
    this.driverStandings = const [],
    this.teamStandings = const [],
    this.weather,
    this.latestResults = const [],
    this.grid = const [],
    this.predictions = const [],
    this.history = const [],
    this.accuracy,
  });

  final LoadStatus status;
  final OpenF1Exception? error;
  final Session? latestSession;
  final Meeting? currentMeeting;
  final Meeting? nextMeeting;
  final List<Meeting> meetings;
  final List<Session> currentSessions;
  final List<Driver> drivers;
  final List<ChampionshipDriver> driverStandings;
  final List<ChampionshipTeam> teamStandings;
  final Weather? weather;
  final List<SessionResult> latestResults;
  final List<StartingGrid> grid;
  final List<DriverPrediction> predictions;
  final List<RaceEvidence> history;
  final ModelAccuracy? accuracy;

  Driver? driverByNumber(int n) {
    for (final d in drivers) {
      if (d.driverNumber == n) return d;
    }
    return null;
  }

  Map<int, int> get effectiveGrid {
    if (grid.isNotEmpty) {
      return {for (final row in grid) row.driverNumber: row.position};
    }
    if (driverStandings.isNotEmpty) {
      return {
        for (final row in driverStandings)
          if (row.positionCurrent != null) row.driverNumber: row.positionCurrent!,
      };
    }
    return {for (final row in latestResults) row.driverNumber: row.position};
  }

  Map<int, double> get championshipPoints => {
        for (final row in driverStandings)
          if (row.pointsCurrent != null) row.driverNumber: row.pointsCurrent!,
      };

  Duration? get countdown {
    final start = nextMeeting?.dateStart ?? latestSession?.dateStart;
    if (start == null) return null;
    final diff = start.toUtc().difference(DateTime.now().toUtc());
    return diff.isNegative ? null : diff;
  }

  AppContextState copyWith({
    LoadStatus? status,
    OpenF1Exception? error,
    Session? latestSession,
    Meeting? currentMeeting,
    Meeting? nextMeeting,
    List<Meeting>? meetings,
    List<Session>? currentSessions,
    List<Driver>? drivers,
    List<ChampionshipDriver>? driverStandings,
    List<ChampionshipTeam>? teamStandings,
    Weather? weather,
    List<SessionResult>? latestResults,
    List<StartingGrid>? grid,
    List<DriverPrediction>? predictions,
    List<RaceEvidence>? history,
    ModelAccuracy? accuracy,
    bool clearError = false,
  }) {
    return AppContextState(
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      latestSession: latestSession ?? this.latestSession,
      currentMeeting: currentMeeting ?? this.currentMeeting,
      nextMeeting: nextMeeting ?? this.nextMeeting,
      meetings: meetings ?? this.meetings,
      currentSessions: currentSessions ?? this.currentSessions,
      drivers: drivers ?? this.drivers,
      driverStandings: driverStandings ?? this.driverStandings,
      teamStandings: teamStandings ?? this.teamStandings,
      weather: weather ?? this.weather,
      latestResults: latestResults ?? this.latestResults,
      grid: grid ?? this.grid,
      predictions: predictions ?? this.predictions,
      history: history ?? this.history,
      accuracy: accuracy ?? this.accuracy,
    );
  }
}

class AppContextCubit extends Cubit<AppContextState> {
  AppContextCubit(this.repository, {AppContextState? seed})
      : super(seed ?? const AppContextState());

  final OpenF1Repository repository;

  Future<void> load() async {
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final latest = await repository.sessions(sessionKey: 'latest');
      if (latest.isEmpty) {
        emit(state.copyWith(status: LoadStatus.empty));
        return;
      }
      final latestSession = latest.first;
      var meetings = await repository.meetings(year: latestSession.year);
      if (meetings.isEmpty) {
        meetings = await repository.meetings(year: latestSession.year - 1);
      }
      meetings = [...meetings]..sort((a, b) => a.dateStart.compareTo(b.dateStart));

      Meeting? currentMeeting;
      for (final m in meetings) {
        if (m.meetingKey == latestSession.meetingKey) currentMeeting = m;
      }
      var currentSessions = await repository.sessions(meetingKey: latestSession.meetingKey);
      currentSessions = [...currentSessions]..sort((a, b) => a.dateStart.compareTo(b.dateStart));

      final now = DateTime.now().toUtc();
      Meeting? upcoming;
      for (final meeting in meetings) {
        if (meeting.dateStart.isAfter(now) && !meeting.meetingName.contains('Testing')) {
          upcoming = meeting;
          break;
        }
      }

      var drivers = await repository.drivers(sessionKey: latestSession.sessionKey);
      if (drivers.isEmpty) {
        drivers = await repository.drivers(sessionKey: 'latest');
      }

      final weatherRows = await repository.weather(sessionKey: latestSession.sessionKey);
      final latestResults = await _safeResults(latestSession.sessionKey);
      Object gridKey = latestSession.sessionKey;
      for (final s in currentSessions) {
        if (s.isRace) gridKey = s.sessionKey;
      }
      final grid = await _safeGrid(gridKey);

      emit(state.copyWith(
        latestSession: latestSession,
        currentMeeting: currentMeeting,
        nextMeeting: upcoming ?? currentMeeting,
        meetings: meetings,
        currentSessions: currentSessions,
        drivers: drivers,
        weather: weatherRows.isEmpty ? null : weatherRows.last,
        latestResults: latestResults,
        grid: grid,
      ));

      await _loadChampionship(latestSession, currentSessions);
      await _loadHistoryAndPredictions();
      emit(state.copyWith(status: LoadStatus.success));
    } on OpenF1Exception catch (e) {
      emit(state.copyWith(status: LoadStatus.error, error: e));
    } catch (_) {
      emit(state.copyWith(status: LoadStatus.error, error: OpenF1Exception.network()));
    }
  }

  Future<void> _loadChampionship(Session latest, List<Session> currentSessions) async {
    Object sessionKey = latest.sessionKey;
    final races = currentSessions.where((s) => s.isRace).toList();
    if (races.isNotEmpty) {
      sessionKey = races.last.sessionKey;
    } else {
      final pastRaces = await repository.sessions(year: latest.year, sessionName: 'Race');
      if (pastRaces.isNotEmpty) {
        pastRaces.sort((a, b) => a.dateStart.compareTo(b.dateStart));
        sessionKey = pastRaces.last.sessionKey;
      }
    }
    try {
      emit(state.copyWith(
        driverStandings: await repository.championshipDrivers(sessionKey: sessionKey),
        teamStandings: await repository.championshipTeams(sessionKey: sessionKey),
      ));
    } on OpenF1Exception {
      emit(state.copyWith(driverStandings: const [], teamStandings: const []));
    }
  }

  Future<List<Session>> _completedRaces(int year) async {
    final races = await repository.sessions(year: year, sessionName: 'Race');
    races.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    return races.where((s) => s.dateEnd.isBefore(DateTime.now().toUtc())).toList();
  }

  Future<void> _loadHistoryAndPredictions() async {
    final year = state.latestSession?.year ?? DateTime.now().year;
    final completed = <Session>[];
    for (var y = year; y >= 2023 && completed.length < 10; y--) {
      try {
        completed.addAll(await _completedRaces(y));
      } on OpenF1Exception {
        continue;
      }
    }
    completed.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    final sample = completed.length > 10 ? completed.sublist(completed.length - 10) : completed;

    final evidence = <RaceEvidence>[];
    final accuracyRows = <RaceAccuracy>[];

    for (final race in sample) {
      try {
        final results = await repository.sessionResults(sessionKey: race.sessionKey);
        if (results.isEmpty) continue;
        final winner = results.first.driverNumber;
        final gridRows = await _safeGrid(race.sessionKey);
        final weatherRows = await repository.weather(sessionKey: race.sessionKey);
        final rain = weatherRows.any((w) => w.isWet);
        StartingGrid? pole;
        for (final g in gridRows) {
          if (g.position == 1) {
            pole = g;
            break;
          }
        }
        final poleNumber = pole?.driverNumber;
        final gridMap = {for (final g in gridRows) g.driverNumber: g.position};
        evidence.add(RaceEvidence(
          winner: winner,
          pole: poleNumber,
          rain: rain,
          leaderDnf: results.any((r) => r.dnf && (r.position == 1 || r.driverNumber == poleNumber)),
          gridPositions: gridMap,
        ));

        Meeting? meeting;
        for (final m in state.meetings) {
          if (m.meetingKey == race.meetingKey) meeting = m;
        }
        final winnerDriver = state.driverByNumber(winner);
        if (meeting != null && winnerDriver != null && evidence.length > 1) {
          final predicted = NaiveBayesPredictor().predict(
            drivers: state.drivers,
            history: evidence.sublist(0, evidence.length - 1),
            currentGrid: gridMap,
            rain: rain,
          );
          if (predicted.isNotEmpty) {
            final brier = predicted.fold<double>(0, (sum, p) {
              final y = p.driver.driverNumber == winner ? 1.0 : 0.0;
              return sum + (p.winProbability - y) * (p.winProbability - y);
            });
            accuracyRows.add(RaceAccuracy(
              meeting: meeting,
              predictedWinner: predicted.first.driver,
              actualWinner: winnerDriver,
              top3Predicted: predicted.take(3).map((p) => p.driver).toList(),
              brierScore: brier,
              hit: predicted.first.driver.driverNumber == winner,
            ));
          }
        }
      } on OpenF1Exception {
        continue;
      }
    }

    ModelAccuracy? accuracy;
    if (accuracyRows.isNotEmpty) {
      final hits = accuracyRows.where((r) => r.hit).length;
      final top3 = accuracyRows
          .where((r) => r.top3Predicted.any((d) => d.driverNumber == r.actualWinner.driverNumber))
          .length;
      accuracy = ModelAccuracy(
        hitRate: hits / accuracyRows.length,
        brierScore: accuracyRows.fold<double>(0, (a, b) => a + b.brierScore) / accuracyRows.length,
        top3Coverage: top3 / accuracyRows.length,
        byRace: accuracyRows,
      );
    }

    emit(state.copyWith(
      history: evidence,
      accuracy: accuracy,
      predictions: NaiveBayesPredictor().predict(
        drivers: state.drivers,
        history: evidence,
        currentGrid: state.effectiveGrid,
        rain: state.weather?.isWet ?? false,
        championshipPoints: state.championshipPoints,
      ),
    ));
  }

  Future<List<SessionResult>> _safeResults(Object sessionKey) async {
    try {
      return await repository.sessionResults(sessionKey: sessionKey);
    } on OpenF1Exception {
      return const [];
    }
  }

  Future<List<StartingGrid>> _safeGrid(Object sessionKey) async {
    try {
      return await repository.startingGrid(sessionKey: sessionKey);
    } on OpenF1Exception {
      return const [];
    }
  }
}
