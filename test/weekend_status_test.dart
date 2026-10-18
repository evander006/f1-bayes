import 'package:f1_app/data/circuits/circuit_layouts.dart';
import 'package:f1_app/data/models/openf1_models.dart';
import 'package:f1_app/domain/weekend_status.dart';
import 'package:f1_app/presentation/bloc/dashboard_board_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live is only reported inside a session window', () {
    final now = DateTime.utc(2026, 5, 24, 14);
    final practice = _session(
      name: 'Practice 1',
      type: 'Practice',
      start: DateTime.utc(2026, 5, 22, 11),
      end: DateTime.utc(2026, 5, 22, 12),
    );
    final race = _session(
      name: 'Race',
      type: 'Race',
      start: DateTime.utc(2026, 5, 24, 13),
      end: DateTime.utc(2026, 5, 24, 15),
    );
    final meeting = _meeting(
      start: DateTime.utc(2026, 5, 22, 11),
      end: DateTime.utc(2026, 5, 24, 16),
    );

    final live = resolveWeekendPhase(sessions: [practice, race], meeting: meeting, now: now);
    expect(live.isLive, isTrue);
    expect(live.code, 'race');

    final before = resolveWeekendPhase(
      sessions: [practice, race],
      meeting: meeting,
      now: DateTime.utc(2026, 5, 23, 18),
    );
    expect(before.isLive, isFalse);
    expect(before.code, 'race');

    final after = resolveWeekendPhase(
      sessions: [practice, race],
      meeting: meeting,
      now: DateTime.utc(2026, 5, 25, 8),
    );
    expect(after.isLive, isFalse);
    expect(after.code, 'finished');
  });

  test('forecast targets the next grand prix after the race finishes', () {
    final current = _meeting(
      key: 10,
      name: 'Monaco Grand Prix',
      start: DateTime.utc(2026, 6, 4),
      end: DateTime.utc(2026, 6, 7),
    );
    final upcoming = _meeting(
      key: 11,
      name: 'Spanish Grand Prix',
      start: DateTime.utc(2026, 6, 11),
      end: DateTime.utc(2026, 6, 14),
    );
    final race = _session(
      name: 'Race',
      type: 'Race',
      start: DateTime.utc(2026, 6, 7, 13),
      end: DateTime.utc(2026, 6, 7, 15),
      meetingKey: 10,
    );

    final during = forecastTargetMeeting(
      current: current,
      upcoming: upcoming,
      currentSessions: [race],
      now: DateTime.utc(2026, 6, 7, 13, 30),
    );
    expect(during?.meetingKey, 10);

    final after = forecastTargetMeeting(
      current: current,
      upcoming: upcoming,
      currentSessions: [race],
      now: DateTime.utc(2026, 6, 8),
    );
    expect(after?.meetingKey, 11);

    final none = forecastTargetMeeting(
      current: current,
      upcoming: null,
      currentSessions: [race],
      now: DateTime.utc(2026, 6, 8),
    );
    expect(none, isNull);
  });

  test('circuit layouts are distinct and unknown circuits are omitted', () {
    final monza = circuitLayoutFor(shortName: 'Monza', location: 'Monza');
    final spa = circuitLayoutFor(shortName: 'Spa-Francorchamps', location: 'Spa');
    final suzuka = circuitLayoutFor(shortName: 'Suzuka', location: 'Suzuka');
    expect(monza, isNotNull);
    expect(spa, isNotNull);
    expect(suzuka, isNotNull);
    expect(monza!.points, isNot(spa!.points));
    expect(monza.points, isNot(suzuka!.points));
    expect(circuitLayoutFor(shortName: 'Nowhere', location: 'Nowhere'), isNull);
  });

  test('a failed refresh keeps the OpenF1 lap trace', () {
    final shown = [
      for (var i = 0; i < 20; i++)
        LocationPoint(
          date: DateTime.utc(2026),
          driverNumber: 1,
          meetingKey: 1,
          sessionKey: 9,
          x: i.toDouble(),
          y: i.toDouble(),
          z: 0,
        ),
    ];
    final kept = retainedTrace(fetched: const [], alreadyShown: shown, sameSession: true);
    expect(kept, shown);
    expect(
      retainedTrace(fetched: const [], alreadyShown: shown, sameSession: false),
      isEmpty,
    );
  });

  test('location samples are downsampled without dropping the ends', () {
    final points = [
      for (var i = 0; i < 20; i++)
        LocationPoint(
          date: DateTime.utc(2026, 1, 1, 0, 0, i),
          driverNumber: 1,
          meetingKey: 1,
          sessionKey: 1,
          x: i.toDouble(),
          y: 0,
          z: 0,
        ),
    ];
    final sampled = downsampleLocations(points, 5);
    expect(sampled.length, greaterThanOrEqualTo(5));
    expect(sampled.first.x, 0);
    expect(sampled.last.x, 19);
  });
}

Meeting _meeting({
  int key = 1,
  String name = 'Test Grand Prix',
  required DateTime start,
  required DateTime end,
}) {
  return Meeting(
    circuitKey: 1,
    circuitShortName: 'Test',
    countryCode: 'TT',
    countryKey: 1,
    countryName: 'Testland',
    dateEnd: end,
    dateStart: start,
    gmtOffset: '+00:00',
    isCancelled: false,
    location: 'Test',
    meetingKey: key,
    meetingName: name,
    meetingOfficialName: name,
    year: start.year,
  );
}

Session _session({
  required String name,
  required String type,
  required DateTime start,
  required DateTime end,
  int meetingKey = 1,
}) {
  return Session(
    circuitKey: 1,
    circuitShortName: 'Test',
    countryCode: 'TT',
    countryKey: 1,
    countryName: 'Testland',
    dateEnd: end,
    dateStart: start,
    gmtOffset: '+00:00',
    isCancelled: false,
    location: 'Test',
    meetingKey: meetingKey,
    sessionKey: name.hashCode,
    sessionName: name,
    sessionType: type,
    year: start.year,
  );
}
