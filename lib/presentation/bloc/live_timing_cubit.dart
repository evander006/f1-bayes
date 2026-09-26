import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/openf1_mqtt.dart';
import '../../data/models/openf1_models.dart';
import '../../data/openf1_exception.dart';
import '../../data/repositories/openf1_repository.dart';
import '../../domain/models/prediction_models.dart';
import 'load_status.dart';

class LiveTimingState {
  const LiveTimingState({
    this.status = LoadStatus.initial,
    this.rows = const [],
    this.unavailable = false,
    this.unavailableReason,
    this.points = const [],
    this.streaming = false,
    this.transport,
  });

  final LoadStatus status;
  final List<LiveClassificationRow> rows;
  final bool unavailable;
  final String? unavailableReason;
  final List<LocationPoint> points;
  final bool streaming;
  final String? transport;
}

class LiveTimingCubit extends Cubit<LiveTimingState> {
  LiveTimingCubit(this._repo) : super(const LiveTimingState());

  final OpenF1Repository _repo;
  Timer? _pollTimer;
  Timer? _emitTimer;
  Timer? _tokenTimer;
  StreamSubscription<OpenF1MqttMessage>? _liveSub;
  bool _inFlight = false;
  Session? _session;
  List<Driver> _drivers = const [];
  List<SessionResult> _fallback = const [];

  final _positions = <int, Position>{};
  final _intervals = <int, Interval>{};
  final _stints = <int, Stint>{};
  final _laps = <int, Lap>{};
  final _points = <LocationPoint>[];

  void start({
    required Session? session,
    required List<Driver> drivers,
    required List<SessionResult> fallback,
  }) {
    _session = session;
    _drivers = drivers;
    _fallback = fallback;
    _pollTimer?.cancel();
    _tokenTimer?.cancel();
    unawaited(_liveSub?.cancel());
    unawaited(_repo.stopLiveStream());
    _positions.clear();
    _intervals.clear();
    _stints.clear();
    _laps.clear();
    _points.clear();
    if (session == null) {
      emit(const LiveTimingState(status: LoadStatus.empty, unavailable: true));
      return;
    }
    unawaited(_bootstrap());
  }

  Future<void> refresh() => _seedFromRest();

  Future<void> _bootstrap() async {
    await _seedFromRest();
    if (isClosed) return;
    try {
      await _repo.startLiveStream();
      _liveSub = _repo.liveMessages.listen(_onLive);
      _scheduleTokenRefresh();
      _publish(immediate: true);
    } catch (_) {
      _startPolling();
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 8), (_) => _seedFromRest());
  }

  void _scheduleTokenRefresh() {
    _tokenTimer?.cancel();
    final expires = _repo.tokenExpiresAt;
    if (expires == null) return;
    final when = expires.subtract(const Duration(minutes: 2));
    final wait = when.difference(DateTime.now());
    if (wait.isNegative) return;
    _tokenTimer = Timer(wait, () async {
      if (isClosed) return;
      try {
        await _repo.stopLiveStream();
        await _repo.startLiveStream();
        _scheduleTokenRefresh();
      } catch (_) {
        _startPolling();
      }
    });
  }

  Future<void> _seedFromRest() async {
    final session = _session;
    if (session == null || _inFlight || isClosed) return;
    _inFlight = true;
    if (state.status == LoadStatus.initial) {
      emit(const LiveTimingState(status: LoadStatus.loading));
    }
    try {
      var positions = await _repo.positions(sessionKey: session.sessionKey);
      for (final p in positions) {
        _upsertPosition(p);
      }
      try {
        for (final row in await _repo.intervals(sessionKey: session.sessionKey)) {
          _upsertInterval(row);
        }
      } on OpenF1Exception {
        // optional
      }
      try {
        for (final row in await _repo.stints(sessionKey: session.sessionKey)) {
          _upsertStint(row);
        }
      } on OpenF1Exception {
        // optional
      }
      try {
        final end = session.dateEnd.isBefore(DateTime.now().toUtc())
            ? session.dateEnd
            : DateTime.now().toUtc();
        final points = await _repo.locations(
          sessionKey: session.sessionKey,
          dateGt: end.subtract(const Duration(seconds: 45)).toIso8601String(),
        );
        if (points.isNotEmpty) {
          _points
            ..clear()
            ..addAll(points.length > 200 ? points.sublist(points.length - 200) : points);
        }
      } on OpenF1Exception {
        // live MQTT will fill the map
      }
      _publish(immediate: true);
    } on OpenF1Exception catch (e) {
      if (isClosed) return;
      emit(LiveTimingState(
        status: LoadStatus.error,
        unavailable: true,
        unavailableReason: e.isSubscription ? 'subscription' : 'error',
        streaming: _repo.isLiveConnected,
        transport: _transportLabel(),
      ));
    } finally {
      _inFlight = false;
    }
  }

  void _onLive(OpenF1MqttMessage message) {
    if (isClosed || !_matchesSession(message.payload)) return;
    switch (message.topic) {
      case 'v1/position':
        _upsertPosition(Position.fromJson(message.payload));
      case 'v1/intervals':
        _upsertInterval(Interval.fromJson(message.payload));
      case 'v1/stints':
        _upsertStint(Stint.fromJson(message.payload));
      case 'v1/laps':
        _upsertLap(Lap.fromJson(message.payload));
      case 'v1/location':
        _points.add(LocationPoint.fromJson(message.payload));
        if (_points.length > 200) {
          _points.removeRange(0, _points.length - 200);
        }
      default:
        break;
    }
    _publish();
  }

  bool _matchesSession(Map<String, dynamic> payload) {
    final session = _session;
    if (session == null) return false;
    final key = payload['session_key'];
    if (key == null || key == 'latest') return true;
    return key.toString() == session.sessionKey.toString();
  }

  void _upsertPosition(Position row) {
    final prev = _positions[row.driverNumber];
    if (prev == null || row.date.isAfter(prev.date)) {
      _positions[row.driverNumber] = row;
    }
  }

  void _upsertInterval(Interval row) {
    final prev = _intervals[row.driverNumber];
    if (prev == null || row.date.isAfter(prev.date)) {
      _intervals[row.driverNumber] = row;
    }
  }

  void _upsertStint(Stint row) {
    final prev = _stints[row.driverNumber];
    if (prev == null || row.stintNumber >= prev.stintNumber) {
      _stints[row.driverNumber] = row;
    }
  }

  void _upsertLap(Lap row) {
    final prev = _laps[row.driverNumber];
    if (prev == null || row.lapNumber >= prev.lapNumber) {
      _laps[row.driverNumber] = row;
    }
  }

  void _publish({bool immediate = false}) {
    if (isClosed) return;
    if (immediate) {
      _emitTimer?.cancel();
      _emitState();
      return;
    }
    if (_emitTimer?.isActive ?? false) return;
    _emitTimer = Timer(const Duration(milliseconds: 250), _emitState);
  }

  void _emitState() {
    if (isClosed) return;
    final rows = _classification();
    final waiting = _session != null &&
        DateTime.now().toUtc().isBefore(_session!.dateStart);
    emit(LiveTimingState(
      status: rows.isEmpty && !waiting ? LoadStatus.empty : LoadStatus.success,
      rows: rows,
      points: List<LocationPoint>.from(_points),
      unavailable: rows.isEmpty,
      unavailableReason: rows.isEmpty ? (waiting ? null : 'historical') : null,
      streaming: _repo.isLiveConnected,
      transport: _transportLabel(),
    ));
  }

  String? _transportLabel() {
    if (_repo.isLiveConnected) return _repo.liveTransport;
    return _pollTimer?.isActive ?? false ? 'rest' : _repo.liveTransport;
  }

  List<LiveClassificationRow> _classification() {
    if (_positions.isEmpty) return _fallbackRows();
    final rows = <LiveClassificationRow>[];
    for (final entry in _positions.entries) {
      final driver = _driver(entry.key);
      if (driver == null) continue;
      rows.add(LiveClassificationRow(
        driver: driver,
        position: entry.value.position,
        interval: _intervals[entry.key],
        stint: _stints[entry.key],
        bestLap: _laps[entry.key],
      ));
    }
    rows.sort((a, b) => a.position.compareTo(b.position));
    return rows;
  }

  List<LiveClassificationRow> _fallbackRows() {
    return [
      for (final result in _fallback)
        if (_driver(result.driverNumber) != null)
          LiveClassificationRow(
            driver: _driver(result.driverNumber)!,
            position: result.position,
          ),
    ];
  }

  Driver? _driver(int n) {
    for (final d in _drivers) {
      if (d.driverNumber == n) return d;
    }
    return null;
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _emitTimer?.cancel();
    _tokenTimer?.cancel();
    await _liveSub?.cancel();
    await _repo.stopLiveStream();
    return super.close();
  }
}
