import '../datasources/openf1_api.dart';
import '../datasources/openf1_mqtt.dart';
import '../models/openf1_models.dart';
import '../openf1_exception.dart';

class OpenF1Repository {
  OpenF1Repository({OpenF1Api? api, OpenF1Mqtt? mqtt})
      : _api = api ?? OpenF1Api(),
        _mqtt = mqtt ?? OpenF1Mqtt();

  final OpenF1Api _api;
  final OpenF1Mqtt _mqtt;

  bool get isAuthenticated => _api.auth.configured;
  bool get isLiveConnected => _mqtt.isConnected;
  String? get liveTransport => _mqtt.transport;
  Stream<OpenF1MqttMessage> get liveMessages => _mqtt.messages;
  DateTime? get tokenExpiresAt => _api.auth.expiresAt;

  Future<String> startLiveStream() async {
    final token = await _api.auth.token();
    if (token == null || token.isEmpty) {
      throw OpenF1Exception.subscription();
    }
    return _mqtt.connect(username: _api.auth.username, token: token);
  }

  Future<void> stopLiveStream() => _mqtt.disconnect();
  final Map<String, _Cache> _cache = {};

  Future<List<Meeting>> meetings({int? year, Object? meetingKey}) {
    return _cached('meetings:$year:$meetingKey', const Duration(hours: 6), () async {
      final rows = await _api.get('/meetings', query: {
        'year': year,
        'meeting_key': meetingKey,
      });
      return rows.map(Meeting.fromJson).toList();
    });
  }

  Future<Session?> lastCompletedRace({int? year}) async {
    final now = DateTime.now().toUtc();
    for (var y = year ?? now.year; y >= 2023; y--) {
      final races = await sessions(year: y, sessionName: 'Race');
      races.sort((a, b) => a.dateStart.compareTo(b.dateStart));
      final done = races.where((s) => !s.isCancelled && s.dateEnd.isBefore(now)).toList();
      if (done.isNotEmpty) return done.last;
    }
    return null;
  }

  Future<List<Session>> sessions({
    int? year,
    Object? meetingKey,
    Object? sessionKey,
    String? sessionName,
    String? sessionType,
  }) {
    return _cached(
      'sessions:$year:$meetingKey:$sessionKey:$sessionName:$sessionType',
      sessionKey == 'latest' ? Duration.zero : const Duration(hours: 1),
      () async {
        final rows = await _api.get('/sessions', query: {
          'year': year,
          'meeting_key': meetingKey,
          'session_key': sessionKey,
          'session_name': sessionName,
          'session_type': sessionType,
        });
        return rows.map(Session.fromJson).toList();
      },
    );
  }

  Future<List<Driver>> drivers({Object? sessionKey, Object? meetingKey}) {
    return _cached(
      'drivers:$sessionKey:$meetingKey',
      sessionKey == 'latest' ? const Duration(minutes: 5) : const Duration(hours: 2),
      () async {
        final rows = await _api.get('/drivers', query: {
          'session_key': sessionKey,
          'meeting_key': meetingKey,
        });
        return rows.map(Driver.fromJson).toList();
      },
    );
  }

  Future<List<Weather>> weather({Object? sessionKey, Object? meetingKey}) async {
    final rows = await _api.get('/weather', query: {
      'session_key': sessionKey,
      'meeting_key': meetingKey,
    });
    return rows.map(Weather.fromJson).toList();
  }

  Future<List<SessionResult>> sessionResults({required Object sessionKey}) async {
    final rows = await _api.get('/session_result', query: {
      'session_key': sessionKey,
    });
    return rows.map(SessionResult.fromJson).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  Future<List<StartingGrid>> startingGrid({required Object sessionKey}) async {
    final rows = await _api.get('/starting_grid', query: {
      'session_key': sessionKey,
    });
    return rows.map(StartingGrid.fromJson).toList()
      ..sort((a, b) => a.position.compareTo(b.position));
  }

  Future<List<ChampionshipDriver>> championshipDrivers({
    required Object sessionKey,
  }) {
    return _cached('champD:$sessionKey', const Duration(minutes: 15), () async {
      final rows = await _api.get('/championship_drivers', query: {
        'session_key': sessionKey,
      });
      return rows.map(ChampionshipDriver.fromJson).toList()
        ..sort((a, b) => (a.positionCurrent ?? 99).compareTo(b.positionCurrent ?? 99));
    });
  }

  Future<List<ChampionshipTeam>> championshipTeams({
    required Object sessionKey,
  }) {
    return _cached('champT:$sessionKey', const Duration(minutes: 15), () async {
      final rows = await _api.get('/championship_teams', query: {
        'session_key': sessionKey,
      });
      return rows.map(ChampionshipTeam.fromJson).toList()
        ..sort((a, b) => (a.positionCurrent ?? 99).compareTo(b.positionCurrent ?? 99));
    });
  }

  Future<List<Position>> positions({required Object sessionKey}) async {
    final rows = await _api.get('/position', query: {'session_key': sessionKey});
    return rows.map(Position.fromJson).toList();
  }

  Future<List<Interval>> intervals({required Object sessionKey}) async {
    final rows = await _api.get('/intervals', query: {'session_key': sessionKey});
    return rows.map(Interval.fromJson).toList();
  }

  Future<List<Lap>> laps({
    required Object sessionKey,
    int? driverNumber,
    int? lapNumber,
  }) async {
    final rows = await _api.get('/laps', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'lap_number': lapNumber,
    });
    return rows.map(Lap.fromJson).toList();
  }

  Future<List<Stint>> stints({required Object sessionKey, int? driverNumber}) async {
    final rows = await _api.get('/stints', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
    });
    return rows.map(Stint.fromJson).toList();
  }

  Future<List<PitStop>> pits({required Object sessionKey, int? driverNumber}) async {
    final rows = await _api.get('/pit', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
    });
    return rows.map(PitStop.fromJson).toList();
  }

  Future<List<Overtake>> overtakes({required Object sessionKey}) async {
    final rows = await _api.get('/overtakes', query: {'session_key': sessionKey});
    return rows.map(Overtake.fromJson).toList();
  }

  Future<List<RaceControlEvent>> raceControl({required Object sessionKey}) async {
    final rows = await _api.get('/race_control', query: {
      'session_key': sessionKey,
    });
    return rows.map(RaceControlEvent.fromJson).toList();
  }

  Future<List<TeamRadio>> teamRadio({required Object sessionKey, int? driverNumber}) async {
    final rows = await _api.get('/team_radio', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
    });
    return rows.map(TeamRadio.fromJson).toList();
  }

  Future<List<CarData>> carData({
    required Object sessionKey,
    required int driverNumber,
    String? dateGt,
  }) async {
    final rows = await _api.get('/car_data', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'date>': dateGt,
    });
    return rows.map(CarData.fromJson).toList();
  }

  Future<List<LocationPoint>> locations({
    required Object sessionKey,
    int? driverNumber,
    String? dateGt,
    String? dateLt,
  }) async {
    final rows = await _api.get('/location', query: {
      'session_key': sessionKey,
      'driver_number': driverNumber,
      'date>': dateGt,
      'date<': dateLt,
    });
    return rows.map(LocationPoint.fromJson).toList();
  }

  Future<T> _cached<T>(String key, Duration ttl, Future<T> Function() load) async {
    final existing = _cache[key];
    if (existing != null &&
        ttl > Duration.zero &&
        DateTime.now().difference(existing.at) < ttl) {
      return existing.data as T;
    }
    final data = await load();
    if (ttl > Duration.zero) {
      _cache[key] = _Cache(data as Object, DateTime.now());
    }
    return data;
  }
}

class _Cache {
  const _Cache(this.data, this.at);
  final Object data;
  final DateTime at;
}
