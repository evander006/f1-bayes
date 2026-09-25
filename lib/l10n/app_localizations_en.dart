// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'F1 Analytics';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get calendar => 'Calendar';

  @override
  String get live => 'Live';

  @override
  String get drivers => 'Drivers';

  @override
  String get teams => 'Teams';

  @override
  String get championship => 'Championship';

  @override
  String get predictions => 'Predictions';

  @override
  String get settings => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String get noData => 'No data available';

  @override
  String get errorGeneric => 'Failed to load data';

  @override
  String get errorSubscription =>
      'Real-time data requires an OpenF1 subscription';

  @override
  String get liveUnavailable => 'Live data unavailable';

  @override
  String get darkMode => 'Dark theme';

  @override
  String get throttle => 'Throttle';

  @override
  String get brake => 'Brake';

  @override
  String get telemetry => 'Telemetry';
}
