import '../../core/l10n/app_strings.dart';
import '../../data/models/openf1_models.dart';

class WeekendStatus {
  const WeekendStatus({
    required this.badge,
    required this.isLive,
    required this.sessionLabel,
  });

  final String badge;
  final bool isLive;
  final String sessionLabel;
}

WeekendStatus describeWeekend({
  required AppStrings strings,
  required Session? liveSession,
  required Session? latestSession,
  required DateTime now,
}) {
  final session = liveSession ?? latestSession;
  if (session == null) {
    return WeekendStatus(
      badge: strings.sessionUpcoming,
      isLive: false,
      sessionLabel: '',
    );
  }
  final running = !now.isBefore(session.dateStart) && now.isBefore(session.dateEnd);
  if (running) {
    return WeekendStatus(
      badge: strings.sessionLive,
      isLive: true,
      sessionLabel: session.sessionName,
    );
  }
  if (now.isBefore(session.dateStart)) {
    return WeekendStatus(
      badge: _typeLabel(strings, session),
      isLive: false,
      sessionLabel: session.sessionName,
    );
  }
  return WeekendStatus(
    badge: strings.sessionFinished,
    isLive: false,
    sessionLabel: session.sessionName,
  );
}

String _typeLabel(AppStrings strings, Session session) {
  final name = session.sessionName.toLowerCase();
  if (name.contains('practice')) return 'Practice';
  if (session.isQualifying) return 'Qualifying';
  if (name.contains('sprint')) return 'Sprint';
  if (session.isRace) return 'Race';
  return strings.sessionUpcoming;
}

String formatCountdown(Duration duration) {
  final days = duration.inDays;
  final hours = duration.inHours % 24;
  final mins = duration.inMinutes % 60;
  final secs = duration.inSeconds % 60;
  if (days > 0) return '${days}d ${hours}h ${mins}m';
  if (hours > 0) return '${hours}h ${mins}m';
  return '${mins}m ${secs.toString().padLeft(2, '0')}s';
}
