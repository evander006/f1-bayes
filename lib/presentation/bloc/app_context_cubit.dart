import 'dart:async';

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
    this.liveSession,
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
  final Session? liveSession;
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

  List<ChampionshipTeam> get visibleTeams {
    final byName = <String, ChampionshipTeam>{
      for (final row in teamStandings)
        if (row.teamName.isNotEmpty) row.teamName: row,
    };
    for (final driver in drivers) {
      if (driver.teamName.isEmpty) continue;
      final existing = byName[driver.teamName];
      if (existing == null) {
        byName[driver.teamName] = ChampionshipTeam(
          teamName: driver.teamName,
          meetingKey: driver.meetingKey,
          sessionKey: driver.sessionKey,
          pointsCurrent: _pointsForTeam(driver.teamName),
        );
        continue;
      }
      if (existing.pointsCurrent == null) {
        byName[driver.teamName] = ChampionshipTeam(
          teamName: existing.teamName,
          meetingKey: existing.meetingKey,
          sessionKey: existing.sessionKey,
          pointsCurrent: _pointsForTeam(driver.teamName),
          pointsStart: existing.pointsStart,
          positionCurrent: existing.positionCurrent,
          positionStart: existing.positionStart,
        );
      }
    }
    return byName.values.toList()
      ..sort((a, b) {
        final pa = a.positionCurrent ?? 99;
        final pb = b.positionCurrent ?? 99;
        if (pa != pb) return pa.compareTo(pb);
        return (b.pointsCurrent ?? -1).compareTo(a.pointsCurrent ?? -1);
      });
  }

  double? _pointsForTeam(String teamName) {
    double? total;
    for (final driver in drivers.where((d) => d.teamName == teamName)) {
      for (final row in driverStandings) {
        if (row.driverNumber != driver.driverNumber || row.pointsCurrent == null) {
          continue;
        }
        total = (total ?? 0) + row.pointsCurrent!;
        break;
      }
    }
    return total;
  }

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
    Session? liveSession,
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
      liveSession: liveSession ?? this.liveSession,
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

Session? resolveLiveSession({
  required Session? latest,
  required List<Session> sessions,
  required DateTime now,
}) {
  final usable = sessions.where((s) => !s.isCancelled).toList()
    ..sort((a, b) => a.dateStart.compareTo(b.dateStart));

  final running = usable
      .where((s) => !now.isBefore(s.dateStart) && now.isBefore(s.dateEnd))
      .toList();
  if (running.isNotEmpty) {
    for (final session in running.reversed) {
      if (session.isRace) return session;
    }
    return running.last;
  }

  for (final session in usable) {
    if (session.dateStart.isAfter(now) &&
        session.dateStart.difference(now) <= const Duration(minutes: 20)) {
      return session;
    }
  }
  return latest;
}

class AppContextCubit extends Cubit<AppContextState> {
  AppContextCubit(this.repository, {AppContextState? seed})
      : super(seed ?? const AppContextState());

  final OpenF1Repository repository;
  Timer? _liveWatch;

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
      final liveSession = resolveLiveSession(
        latest: latestSession,
        sessions: currentSessions,
        now: now,
      );

      emit(state.copyWith(
        latestSession: latestSession,
        liveSession: liveSession,
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
      _watchLiveSession();
    } on OpenF1Exception catch (e) {
      emit(state.copyWith(status: LoadStatus.error, error: e));
    } catch (_) {
      emit(state.copyWith(status: LoadStatus.error, error: OpenF1Exception.network()));
    }
  }

  Future<void> _loadChampionship(Session latest, List<Session> currentSessions) async {
    final keys = <Object>[];
    for (var year = latest.year; year >= 2023 && keys.length < 6; year--) {
      try {
        final races = await _completedRaces(year);
        keys.addAll(races.reversed.map((session) => session.sessionKey));
      } on OpenF1Exception {
        continue;
      }
    }

    var teams = <ChampionshipTeam>[];
    var standings = <ChampionshipDriver>[];
    for (final sessionKey in keys) {
      try {
        final nextTeams = await repository.championshipTeams(sessionKey: sessionKey);
        final nextStandings = await repository.championshipDrivers(sessionKey: sessionKey);
        final hasPoints = nextTeams.any((row) => (row.pointsCurrent ?? 0) > 0) ||
            nextStandings.any((row) => (row.pointsCurrent ?? 0) > 0);
        if (!hasPoints) continue;
        teams = nextTeams;
        standings = nextStandings;
        break;
      } on OpenF1Exception {
        continue;
      }
    }

    if (teams.isEmpty && standings.isNotEmpty) {
      teams = _teamsFromDriverStandings(state.drivers, standings);
    }
    if (teams.isEmpty) {
      teams = _teamsFromDrivers(state.drivers);
    }

    emit(state.copyWith(teamStandings: teams, driverStandings: standings));
  }

  List<ChampionshipTeam> _teamsFromDriverStandings(
    List<Driver> drivers,
    List<ChampionshipDriver> standings,
  ) {
    final points = <String, double>{};
    for (final driver in drivers) {
      if (driver.teamName.isEmpty) continue;
      for (final row in standings) {
        if (row.driverNumber != driver.driverNumber) continue;
        points[driver.teamName] = (points[driver.teamName] ?? 0) + (row.pointsCurrent ?? 0);
        break;
      }
    }
    final ranked = points.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < ranked.length; i++)
        ChampionshipTeam(
          teamName: ranked[i].key,
          meetingKey: drivers.first.meetingKey,
          sessionKey: drivers.first.sessionKey,
          pointsCurrent: ranked[i].value,
          positionCurrent: i + 1,
        ),
    ];
  }

  List<ChampionshipTeam> _teamsFromDrivers(List<Driver> drivers) {
    final seen = <String>{};
    final teams = <ChampionshipTeam>[];
    for (final driver in drivers) {
      if (driver.teamName.isEmpty || !seen.add(driver.teamName)) continue;
      teams.add(ChampionshipTeam(
        teamName: driver.teamName,
        meetingKey: driver.meetingKey,
        sessionKey: driver.sessionKey,
      ));
    }
    teams.sort((a, b) => a.teamName.compareTo(b.teamName));
    return teams;
  }

  Future<List<Session>> _completedRaces(int year) async {
    final races = await repository.sessions(year: year, sessionName: 'Race');
    races.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    final now = DateTime.now().toUtc();
    return races.where((s) => !s.isCancelled && s.dateEnd.isBefore(now)).toList();
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

  void _watchLiveSession() {
    _liveWatch?.cancel();
    _liveWatch = Timer.periodic(const Duration(seconds: 15), (_) => unawaited(_refreshLiveSession()));
  }

  Future<void> _refreshLiveSession() async {
    if (isClosed) return;
    try {
      final latestRows = await repository.sessions(sessionKey: 'latest');
      final latest = latestRows.isNotEmpty ? latestRows.first : state.latestSession;
      var sessions = state.currentSessions;
      if (latest != null &&
          (sessions.isEmpty || latest.meetingKey != sessions.first.meetingKey)) {
        sessions = await repository.sessions(meetingKey: latest.meetingKey);
        sessions = [...sessions]..sort((a, b) => a.dateStart.compareTo(b.dateStart));
      }
      final live = resolveLiveSession(
        latest: latest,
        sessions: sessions,
        now: DateTime.now().toUtc(),
      );
      if (isClosed) return;
      if (live?.sessionKey == state.liveSession?.sessionKey &&
          latest?.sessionKey == state.latestSession?.sessionKey) {
        return;
      }
      emit(state.copyWith(
        latestSession: latest,
        liveSession: live,
        currentSessions: sessions,
      ));
    } on OpenF1Exception {
      if (isClosed) return;
      final next = resolveLiveSession(
        latest: state.latestSession,
        sessions: state.currentSessions,
        now: DateTime.now().toUtc(),
      );
      if (next?.sessionKey != state.liveSession?.sessionKey) {
        emit(state.copyWith(liveSession: next));
      }
    }
  }

  @override
  Future<void> close() {
    _liveWatch?.cancel();
    return super.close();
  }

  Future<List<StartingGrid>> _safeGrid(Object sessionKey) async {
    try {
      return await repository.startingGrid(sessionKey: sessionKey);
    } on OpenF1Exception {
      return const [];
    }
  }
}
