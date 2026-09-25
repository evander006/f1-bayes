// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'F1 Аналитика';

  @override
  String get dashboard => 'Панель';

  @override
  String get calendar => 'Календарь';

  @override
  String get live => 'Эфир';

  @override
  String get drivers => 'Пилоты';

  @override
  String get teams => 'Команды';

  @override
  String get championship => 'Чемпионат';

  @override
  String get predictions => 'Прогноз';

  @override
  String get settings => 'Настройки';

  @override
  String get retry => 'Повторить';

  @override
  String get noData => 'Нет данных';

  @override
  String get errorGeneric => 'Не удалось загрузить данные';

  @override
  String get errorSubscription => 'Live-данные OpenF1 требуют подписку';

  @override
  String get liveUnavailable => 'Live-данные недоступны';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get throttle => 'Газ';

  @override
  String get brake => 'Тормоз';

  @override
  String get telemetry => 'Телеметрия';
}
