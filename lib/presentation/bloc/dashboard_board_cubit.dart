import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/circuits/circuit_layouts.dart';
import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../domain/weekend_status.dart';
import 'app_context_cubit.dart';
import 'load_status.dart';

class TimingEntry {
  const TimingEntry({
    required this.driver,
    required this.position,
    this.gapToLeader,
    this.interval,
    this.bestLap,
    this.lastLap,
    this.sector1,
    this.sector2,
    this.sector3,
    this.compound,
    this.laps,
    this.status = '',
  });

  final Driver driver;
  final int position;
  final String? gapToLeader;
  final String? interval;
  final double? bestLap;
  final double? lastLap;
  final double? sector1;
  final double? sector2;
  final double? sector3;
  final String? compound;
  final int? laps;
  final String status;
}

class BoardState {
  const BoardState({
    this.outlineStatus = LoadStatus.initial,
    this.timingStatus = LoadStatus.initial,
    this.trace = const [],
    this.schematic,
    this.outlineSession,
    this.sectorOrigin,
    this.sector1,
    this.sector2,
    this.cars = const [],
    this.carsTimestamp,
    this.carsSession,
    this.rows = const [],
    this.timingSession,
    this.timingIsLive = false,
    this.fastestLap,
    this.fastestS1,
    this.fastestS2,
    this.fastestS3,
    this.latestFlag,
    this.previousSession,
    this.previousMeeting,
    this.previousResults = const [],
    this.previousGrid = const [],
  });

  final LoadStatus outlineStatus;
  final LoadStatus timingStatus;
  final List<LocationPoint> trace;
  final CircuitLayout? schematic;
  final Session? outlineSession;
  final DateTime? sectorOrigin;
  final double? sector1;
  final double? sector2;
  final List<LocationPoint> cars;
  final DateTime? carsTimestamp;
  final Session? carsSession;
  final List<TimingEntry> rows;
  final Session? timingSession;
  final bool timingIsLive;
  final double? fastestLap;
  final double? fastestS1;
  final double? fastestS2;
  final double? fastestS3;
  final RaceControlEvent? latestFlag;
  final Session? previousSession;
  final Meeting? previousMeeting;
  final List<SessionResult> previousResults;
  final List<StartingGrid> previousGrid;

  bool get hasOutline => trace.length >= 2 || (schematic != null && schematic!.points.length >= 2);

  BoardState copyWith({
    LoadStatus? outlineStatus,
    LoadStatus? timingStatus,
  }) {
    return BoardState(
      outlineStatus: outlineStatus ?? this.outlineStatus,
      timingStatus: timingStatus ?? this.timingStatus,
      trace: trace,
      schematic: schematic,
      outlineSession: outlineSession,
      sectorOrigin: sectorOrigin,
      sector1: sector1,
      sector2: sector2,
      cars: cars,
      carsTimestamp: carsTimestamp,
      carsSession: carsSession,
      rows: rows,
      timingSession: timingSession,
      timingIsLive: timingIsLive,
      fastestLap: fastestLap,
      fastestS1: fastestS1,
      fastestS2: fastestS2,
      fastestS3: fastestS3,
      latestFlag: latestFlag,
      previousSession: previousSession,
      previousMeeting: previousMeeting,
      previousResults: previousResults,
      previousGrid: previousGrid,
    );
  }
}

class DashboardBoardCubit extends Cubit<BoardState> {
  DashboardBoardCubit(this._repo) : super(const BoardState());

  final OpenF1Repository _repo;
  int _gen = 0;
  String? _token;
  Future<void>? _running;
  AppContextState? _queued;
  final Map<int, _Outline> _traces = {};

  Future<void> load(AppContextState app) {
    if (_running != null) {
      _queued = app;
      return _running!;
    }
    final run = _load(app);
    _running = run;
    return run.whenComplete(() {
      _running = null;
      final queued = _queued;
      _queued = null;
      if (queued != null && !isClosed) {
        return load(queued);
      }
    });
  }

  Future<void> _load(AppContextState app) async {
    final now = DateTime.now().toUtc();
    final live = activeSession(app.currentSessions, now) ??
        (app.latestSession != null && sessionIsActive(app.latestSession!, now) ? app.latestSession : null);
    final token = '${app.refreshedAt?.microsecondsSinceEpoch}-${app.latestSession?.sessionKey}-${live?.sessionKey}';
    if (token == _token && state.timingStatus == LoadStatus.success) return;
    _token = token;
    final gen = ++_gen;
    final session = live ?? app.latestSession;
    if (session == null) {
      if (!isClosed) {
        emit(const BoardState(outlineStatus: LoadStatus.empty, timingStatus: LoadStatus.empty));
      }
      return;
    }
    if (state.outlineStatus == LoadStatus.initial && !isClosed) {
      emit(state.copyWith(outlineStatus: LoadStatus.loading, timingStatus: LoadStatus.loading));
    }

    final meeting = _meetingFor(app, session);
    final results = await _resultsFor(app, session);
    if (gen != _gen || isClosed) return;

    final outline = _keepTrace(
      await _outlineFor(session, results, app.drivers, meeting),
      session,
    );
    if (gen != _gen || isClosed) return;

    final timing = await _timingFor(session, results, app.drivers, live != null);
    if (gen != _gen || isClosed) return;

    final cars = live != null
        ? (points: const <LocationPoint>[], at: null)
        : await _carSnapshot(session);
    if (gen != _gen || isClosed) return;

    final flag = await _flagFor(session);
    if (gen != _gen || isClosed) return;

    final previous = await _previousRace(app, session, results);
    if (gen != _gen || isClosed) return;

    emit(BoardState(
      outlineStatus: outline.trace.length >= 2 || outline.schematic != null
          ? LoadStatus.success
          : LoadStatus.empty,
      timingStatus: timing.rows.isEmpty ? LoadStatus.empty : LoadStatus.success,
      trace: outline.trace,
      schematic: outline.schematic,
      outlineSession: outline.trace.length >= 2 ? session : null,
      sectorOrigin: outline.origin,
      sector1: outline.sector1,
      sector2: outline.sector2,
      cars: cars.points,
      carsTimestamp: cars.at,
      carsSession: cars.points.isEmpty ? null : session,
      rows: timing.rows,
      timingSession: session,
      timingIsLive: live != null,
      fastestLap: timing.fastestLap,
      fastestS1: timing.fastestS1,
      fastestS2: timing.fastestS2,
      fastestS3: timing.fastestS3,
      latestFlag: flag,
      previousSession: previous.session,
      previousMeeting: previous.meeting,
      previousResults: previous.results,
      previousGrid: previous.grid,
    ));
  }

  Meeting? _meetingFor(AppContextState app, Session session) {
    for (final meeting in app.meetings) {
      if (meeting.meetingKey == session.meetingKey) return meeting;
    }
    return app.currentMeeting;
  }

  Future<List<SessionResult>> _resultsFor(AppContextState app, Session session) async {
    if (app.latestSession?.sessionKey == session.sessionKey && app.latestResults.isNotEmpty) {
      return app.latestResults;
    }
    try {
      return await _repo.sessionResults(sessionKey: session.sessionKey);
    } on OpenF1Exception {
      return const [];
    }
  }

  _Outline _keepTrace(_Outline fetched, Session session) {
    final sameSession = state.outlineSession?.sessionKey == session.sessionKey;
    final cached = _traces[session.sessionKey];
    final kept = retainedTrace(
      fetched: fetched.trace,
      alreadyShown: cached?.trace ?? (sameSession ? state.trace : const <LocationPoint>[]),
      sameSession: true,
    );
    if (fetched.trace.length >= 12) {
      _traces[session.sessionKey] = fetched;
      return fetched;
    }
    if (cached != null && identical(kept, cached.trace)) return cached;
    if (kept.length >= 12) {
      return _Outline(
        trace: kept,
        origin: state.sectorOrigin,
        sector1: state.sector1,
        sector2: state.sector2,
      );
    }
    return fetched;
  }

  Future<_Outline> _outlineFor(
    Session session,
    List<SessionResult> results,
    List<Driver> drivers,
    Meeting? meeting,
  ) async {
    final cached = _traces[session.sessionKey];
    if (cached != null && cached.trace.length >= 12) return cached;

    final driverNumber = _referenceDriver(results, drivers);
    if (driverNumber != null) {
      try {
        final laps = await _repo.laps(sessionKey: session.sessionKey, driverNumber: driverNumber);
        final flying = laps.where((lap) {
          final time = lap.lapDuration;
          return lap.dateStart != null && time != null && time > 40 && !lap.isPitOutLap;
        }).toList()
          ..sort((a, b) => a.lapDuration!.compareTo(b.lapDuration!));
        for (final lap in flying.take(3)) {
          final start = lap.dateStart!.toUtc();
          final end = start.add(Duration(milliseconds: (lap.lapDuration! * 1000).round() + 500));
          final points = await _repo.locations(
            sessionKey: session.sessionKey,
            driverNumber: driverNumber,
            dateGt: start.toIso8601String(),
            dateLt: end.toIso8601String(),
          );
          points.sort((a, b) => a.date.compareTo(b.date));
          final trace = downsampleLocations(points, 240);
          if (trace.length >= 12) {
            final outline = _Outline(
              trace: trace,
              origin: start,
              sector1: lap.durationSector1,
              sector2: lap.durationSector2,
            );
            _traces[session.sessionKey] = outline;
            return outline;
          }
        }
      } on OpenF1Exception {
        final remembered = _traces[session.sessionKey];
        if (remembered != null && remembered.trace.length >= 12) return remembered;
      }
    }

    final layout = circuitLayoutFor(
      shortName: meeting?.circuitShortName ?? session.circuitShortName,
      location: meeting?.location ?? session.location,
    );
    return _Outline(schematic: layout);
  }

  int? _referenceDriver(List<SessionResult> results, List<Driver> drivers) {
    for (final result in results) {
      if (result.position == 1 && !result.dns) return result.driverNumber;
    }
    if (drivers.isEmpty) return null;
    return drivers.first.driverNumber;
  }

  Future<_Timing> _timingFor(
    Session session,
    List<SessionResult> results,
    List<Driver> drivers,
    bool live,
  ) async {
    if (results.isEmpty) return const _Timing();
    List<Lap> laps = const [];
    List<Stint> stints = const [];
    List<Interval> intervals = const [];
    try {
      laps = await _repo.laps(sessionKey: session.sessionKey);
    } on OpenF1Exception {
      laps = const [];
    }
    try {
      stints = await _repo.stints(sessionKey: session.sessionKey);
    } on OpenF1Exception {
      stints = const [];
    }
    try {
      final anchor = session.dateEnd.isBefore(DateTime.now().toUtc()) ? session.dateEnd : DateTime.now().toUtc();
      intervals = await _repo.intervals(
        sessionKey: session.sessionKey,
        dateGt: anchor.subtract(const Duration(seconds: 45)).toIso8601String(),
      );
    } on OpenF1Exception {
      intervals = const [];
    }

    final lapsByDriver = <int, List<Lap>>{};
    for (final lap in laps) {
      lapsByDriver.putIfAbsent(lap.driverNumber, () => []).add(lap);
    }
    final stintByDriver = <int, Stint>{};
    for (final stint in stints) {
      final prev = stintByDriver[stint.driverNumber];
      if (prev == null || stint.stintNumber >= prev.stintNumber) {
        stintByDriver[stint.driverNumber] = stint;
      }
    }
    final intervalByDriver = <int, Interval>{};
    for (final row in intervals) {
      final prev = intervalByDriver[row.driverNumber];
      if (prev == null || row.date.isAfter(prev.date)) {
        intervalByDriver[row.driverNumber] = row;
      }
    }

    final entries = <TimingEntry>[];
    double? fastest;
    double? fastestS1;
    double? fastestS2;
    double? fastestS3;
    for (final result in results) {
      final driver = _driver(drivers, result.driverNumber);
      if (driver == null) continue;
      final driverLaps = lapsByDriver[result.driverNumber] ?? const <Lap>[];
      final best = _bestLap(driverLaps);
      final last = _lastLap(driverLaps);
      final gap = intervalByDriver[result.driverNumber]?.gapToLeaderLabel ?? result.gapToLeader;
      final interval = intervalByDriver[result.driverNumber]?.intervalLabel;
      if (best != null && (fastest == null || best < fastest)) fastest = best;
      final s1 = last?.durationSector1;
      final s2 = last?.durationSector2;
      final s3 = last?.durationSector3;
      for (final lap in driverLaps) {
        final lapS1 = lap.durationSector1;
        final lapS2 = lap.durationSector2;
        final lapS3 = lap.durationSector3;
        if (lapS1 != null && lapS1 > 5 && (fastestS1 == null || lapS1 < fastestS1)) fastestS1 = lapS1;
        if (lapS2 != null && lapS2 > 5 && (fastestS2 == null || lapS2 < fastestS2)) fastestS2 = lapS2;
        if (lapS3 != null && lapS3 > 5 && (fastestS3 == null || lapS3 < fastestS3)) fastestS3 = lapS3;
      }
      entries.add(TimingEntry(
        driver: driver,
        position: result.position,
        gapToLeader: result.position == 1 ? 'LEADER' : gap,
        interval: result.position == 1 ? 'LEADER' : interval,
        bestLap: best,
        lastLap: last?.lapDuration,
        sector1: s1,
        sector2: s2,
        sector3: s3,
        compound: stintByDriver[result.driverNumber]?.compound,
        laps: result.numberOfLaps ?? (driverLaps.isEmpty ? null : driverLaps.map((lap) => lap.lapNumber).reduce((a, b) => a > b ? a : b)),
        status: _status(result, live: live),
      ));
    }
    entries.sort((a, b) => a.position.compareTo(b.position));
    return _Timing(
      rows: entries,
      fastestLap: fastest,
      fastestS1: fastestS1,
      fastestS2: fastestS2,
      fastestS3: fastestS3,
    );
  }

  Driver? _driver(List<Driver> drivers, int number) {
    for (final driver in drivers) {
      if (driver.driverNumber == number) return driver;
    }
    return null;
  }

  double? _bestLap(List<Lap> laps) {
    double? best;
    for (final lap in laps) {
      final time = lap.lapDuration;
      if (lap.isPitOutLap || time == null || time < 30) continue;
      if (best == null || time < best) best = time;
    }
    return best;
  }

  Lap? _lastLap(List<Lap> laps) {
    Lap? last;
    for (final lap in laps) {
      if (last == null || lap.lapNumber >= last.lapNumber) last = lap;
    }
    return last;
  }

  String _status(SessionResult result, {required bool live}) {
    if (result.dsq) return 'dsq';
    if (result.dns) return 'dns';
    if (result.dnf) return 'retired';
    return live ? 'on_track' : 'classified';
  }

  Future<({List<LocationPoint> points, DateTime? at})> _carSnapshot(Session session) async {
    try {
      final end = session.dateEnd.toUtc();
      final points = await _repo.locations(
        sessionKey: session.sessionKey,
        dateGt: end.subtract(const Duration(seconds: 8)).toIso8601String(),
      );
      final window = points.length > 2500 ? points.sublist(points.length - 2500) : points;
      final latest = <int, LocationPoint>{};
      for (final point in window) {
        final prev = latest[point.driverNumber];
        if (prev == null || point.date.isAfter(prev.date)) {
          latest[point.driverNumber] = point;
        }
      }
      if (latest.isEmpty) return (points: const <LocationPoint>[], at: null);
      final values = latest.values.toList()..sort((a, b) => a.date.compareTo(b.date));
      return (points: values, at: values.last.date);
    } on OpenF1Exception {
      return (points: const <LocationPoint>[], at: null);
    }
  }

  Future<RaceControlEvent?> _flagFor(Session session) async {
    try {
      final events = await _repo.raceControl(sessionKey: session.sessionKey);
      RaceControlEvent? latest;
      for (final event in events) {
        final flag = event.flag;
        if (flag == null || flag.isEmpty) continue;
        if (latest == null || event.date.isAfter(latest.date)) latest = event;
      }
      return latest;
    } on OpenF1Exception {
      return null;
    }
  }

  Future<_Previous> _previousRace(
    AppContextState app,
    Session displayed,
    List<SessionResult> displayedResults,
  ) async {
    final now = DateTime.now().toUtc();
    if (displayed.isRace && displayed.dateEnd.isBefore(now)) {
      return _Previous(
        session: displayed,
        meeting: _meetingFor(app, displayed),
        results: displayedResults,
        grid: app.latestGrid,
      );
    }
    try {
      final race = await _repo.lastCompletedRace(year: displayed.year);
      if (race == null) return const _Previous();
      if (race.sessionKey == displayed.sessionKey) {
        return _Previous(
          session: race,
          meeting: _meetingFor(app, race),
          results: displayedResults,
          grid: app.latestGrid,
        );
      }
      final results = await _repo.sessionResults(sessionKey: race.sessionKey);
      List<StartingGrid> grid = const [];
      try {
        grid = await _repo.startingGrid(sessionKey: race.sessionKey);
      } on OpenF1Exception {
        grid = const [];
      }
      return _Previous(
        session: race,
        meeting: _meetingFor(app, race),
        results: results,
        grid: grid,
      );
    } on OpenF1Exception {
      return const _Previous();
    }
  }
}

class _Outline {
  const _Outline({
    this.trace = const [],
    this.schematic,
    this.origin,
    this.sector1,
    this.sector2,
  });

  final List<LocationPoint> trace;
  final CircuitLayout? schematic;
  final DateTime? origin;
  final double? sector1;
  final double? sector2;
}

class _Timing {
  const _Timing({
    this.rows = const [],
    this.fastestLap,
    this.fastestS1,
    this.fastestS2,
    this.fastestS3,
  });

  final List<TimingEntry> rows;
  final double? fastestLap;
  final double? fastestS1;
  final double? fastestS2;
  final double? fastestS3;
}

class _Previous {
  const _Previous({
    this.session,
    this.meeting,
    this.results = const [],
    this.grid = const [],
  });

  final Session? session;
  final Meeting? meeting;
  final List<SessionResult> results;
  final List<StartingGrid> grid;
}

/// A failed refresh must not replace a real OpenF1 lap trace with the schematic.
List<LocationPoint> retainedTrace({
  required List<LocationPoint> fetched,
  required List<LocationPoint> alreadyShown,
  required bool sameSession,
}) {
  if (fetched.length >= 12) return fetched;
  if (sameSession && alreadyShown.length >= 12) return alreadyShown;
  return fetched;
}

List<LocationPoint> downsampleLocations(List<LocationPoint> points, int max) {
  if (points.length <= max) return points;
  final step = points.length / max;
  final out = <LocationPoint>[];
  for (var i = 0; i < max; i++) {
    out.add(points[(i * step).floor()]);
  }
  final last = points.last;
  if (out.last.date != last.date || out.last.x != last.x || out.last.y != last.y) {
    out.add(last);
  }
  return out;
}
