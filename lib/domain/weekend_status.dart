import '../data/models/openf1_models.dart';

bool sessionIsActive(Session session, DateTime now) {
  if (session.isCancelled) return false;
  final instant = now.toUtc();
  return !instant.isBefore(session.dateStart.toUtc()) && instant.isBefore(session.dateEnd.toUtc());
}

/// The session that is actually running. Returns null when nothing is in its time window.
Session? activeSession(Iterable<Session> sessions, DateTime now) {
  final running = sessions.where((session) => sessionIsActive(session, now)).toList()
    ..sort((a, b) => a.dateStart.compareTo(b.dateStart));
  if (running.isEmpty) return null;
  for (final session in running.reversed) {
    if (session.isRace) return session;
  }
  return running.last;
}

Session? nextScheduledSession(Iterable<Session> sessions, DateTime now) {
  final instant = now.toUtc();
  final upcoming = sessions
      .where((session) => !session.isCancelled && session.dateStart.toUtc().isAfter(instant))
      .toList()
    ..sort((a, b) => a.dateStart.compareTo(b.dateStart));
  if (upcoming.isEmpty) return null;
  return upcoming.first;
}

String sessionKind(Session session) {
  final name = '${session.sessionName} ${session.sessionType}'.toLowerCase();
  if (name.contains('practice')) return 'practice';
  if (name.contains('sprint') && name.contains('qualifying')) return 'sprintQualifying';
  if (name.contains('qualifying')) return 'qualifying';
  if (name.contains('sprint')) return 'sprint';
  if (session.isRace || name.contains('race')) return 'race';
  return 'session';
}

class WeekendPhase {
  const WeekendPhase({required this.isLive, required this.code, this.session});

  final bool isLive;
  final String code;
  final Session? session;
}

WeekendPhase resolveWeekendPhase({
  required List<Session> sessions,
  required Meeting? meeting,
  required DateTime now,
}) {
  final instant = now.toUtc();
  final active = activeSession(sessions, instant);
  if (active != null) {
    return WeekendPhase(isLive: true, code: sessionKind(active), session: active);
  }

  final next = nextScheduledSession(sessions, instant);
  final inWeekend = meeting != null &&
      !meeting.isCancelled &&
      !instant.isBefore(meeting.dateStart.toUtc()) &&
      !instant.isAfter(meeting.dateEnd.toUtc());
  if (inWeekend && next != null) {
    return WeekendPhase(isLive: false, code: sessionKind(next), session: next);
  }
  if (meeting != null && meeting.dateStart.toUtc().isAfter(instant)) {
    return WeekendPhase(isLive: false, code: 'upcoming', session: next);
  }

  final usable = sessions.where((session) => !session.isCancelled).toList();
  if (usable.isNotEmpty && usable.every((session) => !session.dateEnd.toUtc().isAfter(instant))) {
    return const WeekendPhase(isLive: false, code: 'finished');
  }
  if (next != null) {
    return WeekendPhase(isLive: false, code: sessionKind(next), session: next);
  }
  return const WeekendPhase(isLive: false, code: 'finished');
}

/// Grand Prix the win model should be aimed at.
///
/// While this weekend's race is still open, that race is the target.
/// After it finishes, the next published Grand Prix is the target.
Meeting? forecastTargetMeeting({
  required Meeting? current,
  required Meeting? upcoming,
  required List<Session> currentSessions,
  required DateTime now,
}) {
  final instant = now.toUtc();
  final currentOpen = current != null &&
      !current.isCancelled &&
      !_isTesting(current) &&
      currentSessions.any(
        (session) => session.isRace && !session.isCancelled && session.dateEnd.toUtc().isAfter(instant),
      );
  if (currentOpen) return current;
  if (upcoming != null && !upcoming.isCancelled && !_isTesting(upcoming)) return upcoming;
  return null;
}

Meeting? headerMeeting({
  required Meeting? current,
  required Meeting? upcoming,
  required DateTime now,
}) {
  final instant = now.toUtc();
  if (current != null &&
      !current.isCancelled &&
      !instant.isBefore(current.dateStart.toUtc()) &&
      !instant.isAfter(current.dateEnd.toUtc())) {
    return current;
  }
  if (upcoming != null && !upcoming.isCancelled && !_isTesting(upcoming)) return upcoming;
  return current;
}

bool _isTesting(Meeting meeting) => meeting.meetingName.toLowerCase().contains('testing');
