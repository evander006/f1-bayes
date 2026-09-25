import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

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
  });

  final LoadStatus status;
  final List<LiveClassificationRow> rows;
  final bool unavailable;
  final String? unavailableReason;
  final List<LocationPoint> points;
}

class LiveTimingCubit extends Cubit<LiveTimingState> {
  LiveTimingCubit(this._repo) : super(const LiveTimingState());

  final OpenF1Repository _repo;
  Timer? _timer;
  bool _inFlight = false;
  Session? _session;
  List<Driver> _drivers = const [];
  List<SessionResult> _fallback = const [];

  void start({
    required Session? session,
    required List<Driver> drivers,
    required List<SessionResult> fallback,
  }) {
    _session = session;
    _drivers = drivers;
    _fallback = fallback;
    _timer?.cancel();
    if (session == null) {
      emit(const LiveTimingState(status: LoadStatus.empty, unavailable: true));
      return;
    }
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 8), (_) => refresh());
  }

  Future<void> refresh() async {
    final session = _session;
    if (session == null || _inFlight || isClosed) return;
    _inFlight = true;
    if (state.status == LoadStatus.initial) {
      emit(const LiveTimingState(status: LoadStatus.loading));
    }
    try {
      final positions = await _repo.positions(sessionKey: session.sessionKey);
      if (positions.isEmpty) {
        final rows = [
          for (final result in _fallback)
            if (_driver(result.driverNumber) != null)
              LiveClassificationRow(
                driver: _driver(result.driverNumber)!,
                position: result.position,
              ),
        ];
        emit(LiveTimingState(
          status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success,
          rows: rows,
          unavailable: rows.isEmpty,
          unavailableReason: rows.isEmpty ? 'historical' : null,
        ));
        return;
      }

      final latestPos = <int, Position>{};
      for (final p in positions) {
        final prev = latestPos[p.driverNumber];
        if (prev == null || p.date.isAfter(prev.date)) latestPos[p.driverNumber] = p;
      }

      var unavailable = false;
      String? reason;
      List<Interval> intervals = const [];
      List<Stint> stints = const [];
      try {
        intervals = await _repo.intervals(sessionKey: session.sessionKey);
      } on OpenF1Exception catch (e) {
        if (e.isSubscription) {
          unavailable = true;
          reason = 'subscription';
        }
      }
      try {
        stints = await _repo.stints(sessionKey: session.sessionKey);
      } on OpenF1Exception {
        // optional
      }

      List<LocationPoint> points = const [];
      try {
        final end = session.dateEnd.isBefore(DateTime.now().toUtc())
            ? session.dateEnd
            : DateTime.now().toUtc();
        points = await _repo.locations(
          sessionKey: session.sessionKey,
          dateGt: end.subtract(const Duration(seconds: 30)).toIso8601String(),
        );
        if (points.length > 200) {
          points = points.sublist(points.length - 200);
        }
      } on OpenF1Exception {
        points = const [];
      }

      final latestInt = <int, Interval>{};
      for (final i in intervals) {
        final prev = latestInt[i.driverNumber];
        if (prev == null || i.date.isAfter(prev.date)) latestInt[i.driverNumber] = i;
      }
      final latestStint = <int, Stint>{};
      for (final s in stints) {
        final prev = latestStint[s.driverNumber];
        if (prev == null || s.stintNumber >= prev.stintNumber) {
          latestStint[s.driverNumber] = s;
        }
      }

      final rows = <LiveClassificationRow>[];
      for (final entry in latestPos.entries) {
        final driver = _driver(entry.key);
        if (driver == null) continue;
        rows.add(LiveClassificationRow(
          driver: driver,
          position: entry.value.position,
          interval: latestInt[entry.key],
          stint: latestStint[entry.key],
        ));
      }
      rows.sort((a, b) => a.position.compareTo(b.position));
      emit(LiveTimingState(
        status: rows.isEmpty ? LoadStatus.empty : LoadStatus.success,
        rows: rows,
        unavailable: unavailable,
        unavailableReason: reason,
        points: points,
      ));
    } on OpenF1Exception catch (e) {
      emit(LiveTimingState(
        status: LoadStatus.error,
        unavailable: true,
        unavailableReason: e.isSubscription ? 'subscription' : 'error',
      ));
    } finally {
      _inFlight = false;
    }
  }

  Driver? _driver(int n) {
    for (final d in _drivers) {
      if (d.driverNumber == n) return d;
    }
    return null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
