class AppStrings {
  const AppStrings(this.isRu);

  final bool isRu;

  static const en = AppStrings(false);
  static const ru = AppStrings(true);

  String get appName => isRu ? 'F1 Аналитика' : 'F1 Analytics';
  String get dashboard => isRu ? 'Панель' : 'Dashboard';
  String get cars => isRu ? 'Машины' : 'Cars';
  String get weather => isRu ? 'Погода' : 'Weather';
  String get tracker => isRu ? 'Трекер' : 'Tracker';
  String get grid => isRu ? 'Сетка' : 'Grid';
  String get drivers => isRu ? 'Пилоты' : 'Drivers';
  String get constructors => isRu ? 'Кубок' : 'Constructors';
  String get races => isRu ? 'Гонки' : 'Races';
  String get accuracy => isRu ? 'Точность' : 'Accuracy';
  String get settings => isRu ? 'Настройки' : 'Settings';
  String get live => isRu ? 'Эфир' : 'Live';
  String get predictions => isRu ? 'Прогноз' : 'Predictions';

  String get nextRace => isRu ? 'Следующая гонка' : 'Next Race';
  String get currentPole => isRu ? 'Текущий поул' : 'Current Pole';
  String get humidity => isRu ? 'Влажность' : 'Humidity';
  String get top5 =>
      isRu ? 'Топ-5 вероятностей победы' : 'Top 5 Predicted Win Probabilities';
  String get modelAccuracy => isRu ? 'Точность модели' : 'Model Accuracy';
  String get hitRate => isRu ? 'Hit Rate' : 'Hit Rate';
  String get brierScore => isRu ? 'Brier Score' : 'Brier Score';
  String get currentLeader => isRu ? 'Лидер гонки' : 'Current Race Leader';
  String get winProbability =>
      isRu ? 'Вероятность победы — все пилоты' : 'Win Probability — All Drivers';
  String get featureContribution =>
      isRu ? 'Вклад байесовских признаков' : 'Bayesian Feature Contribution';
  String get pole => isRu ? 'Поул' : 'Pole';
  String get gridPos => isRu ? 'Стартовая позиция' : 'Grid Position';
  String get rain => isRu ? 'Вероятность дождя' : 'Rain Probability';
  String get form => isRu ? 'Текущая форма' : 'Recent Form';
  String get team => isRu ? 'Сила команды' : 'Team Strength';
  String get leaderDnf => isRu ? 'Сход лидера (what-if)' : 'Leader DNF (What-if)';
  String get leaderDnfHint => isRu
      ? 'Пересчитать вероятности без текущего лидера'
      : 'Recalculate probabilities without the current leader';
  String get heroTitle =>
      isRu ? 'Точнее прогнозы.\nУмнее решения.' : 'Better predictions.\nSmarter decisions.';
  String get classification => isRu ? 'Классификация' : 'Classification';
  String get selectedDriver => isRu ? 'Выбранный пилот' : 'Selected Driver';
  String get qualifyingGrid => isRu ? 'Квалификация / Сетка' : 'Qualifying / Grid';
  String get trackMap => isRu ? 'Карта трассы' : 'Track Map';
  String get trackDemo =>
      isRu ? 'Демо: повтор последней гонки' : 'Demo: last race replay';
  String get speed => isRu ? 'Скорость' : 'Speed';
  String get throttle => isRu ? 'Газ' : 'Throttle';
  String get brake => isRu ? 'Тормоз' : 'Brake';
  String get rpm => isRu ? 'Обороты' : 'RPM';
  String get gear => isRu ? 'Передача' : 'Gear';
  String get drs => isRu ? 'DRS' : 'DRS';
  String get tyreAge => isRu ? 'возраст' : 'age';
  String get gap => isRu ? 'Отрыв' : 'Gap';
  String get toLeader => isRu ? 'До лидера' : 'To leader';
  String get toAhead => isRu ? 'До впереди' : 'Ahead';
  String get tyre => isRu ? 'Шины' : 'Tyre';
  String get lap => isRu ? 'Круг' : 'Lap';
  String get vsLast5 => isRu ? 'к последним 5' : 'vs. last 5 races';
  String get predictionVsResult =>
      isRu ? 'Прогноз vs результат' : 'Prediction vs Result';
  String get date => isRu ? 'Дата' : 'Date';
  String get predicted => isRu ? 'Прогноз / факт' : 'Predicted / real';
  String get top3 => isRu ? 'Топ-3 прогноз' : 'Top-3 Predicted';
  String get winner => isRu ? 'Победитель' : 'Winner';
  String get comingSoon => isRu ? 'Скоро' : 'Coming soon';
  String get driverDetail => isRu ? 'Пилот' : 'Driver Detail';
  String get history => isRu ? 'История' : 'History';
  String get liveTracker => isRu ? 'Live-трекер' : 'Live Tracker';
  String get pos => isRu ? 'Поз' : 'Pos';
  String get driver => isRu ? 'Пилот' : 'Driver';
  String get probability => isRu ? 'Вероятность' : 'Probability';
  String get calendar => isRu ? 'Календарь' : 'Calendar';
  String get championship => isRu ? 'Чемпионат' : 'Championship';
  String get teams => isRu ? 'Команды' : 'Teams';
  String get more => isRu ? 'Ещё' : 'More';
  String get search => isRu ? 'Поиск' : 'Search';
  String get retry => isRu ? 'Повторить' : 'Retry';
  String get noData => isRu ? 'Нет данных' : 'No data available';
  String get loading => isRu ? 'Загрузка' : 'Loading';
  String get errorGeneric => isRu ? 'Не удалось загрузить данные' : 'Failed to load data';
  String get errorTimeout => isRu ? 'Превышено время ожидания' : 'Request timed out';
  String get errorNetwork => isRu ? 'Нет сети' : 'Network unavailable';
  String get errorHttp => isRu ? 'Ошибка сервера OpenF1' : 'OpenF1 server error';
  String get errorMalformed => isRu ? 'Некорректный ответ API' : 'Malformed API response';
  String get errorSubscription => isRu
      ? 'Live-данные OpenF1 требуют подписку'
      : 'Real-time data requires an OpenF1 subscription';
  String get liveUnavailable => isRu ? 'Live-данные недоступны' : 'Live data unavailable';
  String get liveAuthenticated =>
      isRu ? 'Live API: авторизовано' : 'Live API: authenticated';
  String get liveMqtt => isRu ? 'Эфир: MQTT' : 'Live: MQTT';
  String get liveWebsocket => isRu ? 'Эфир: WebSocket' : 'Live: WebSocket';
  String get liveRestFallback => isRu ? 'Эфир: REST polling' : 'Live: REST polling';
  String get usingLatestSession =>
      isRu ? 'Показана последняя доступная сессия' : 'Showing the latest available session';
  String get sessions => isRu ? 'Сессии' : 'Sessions';
  String get results => isRu ? 'Результаты' : 'Results';
  String get pits => isRu ? 'Пит-стопы' : 'Pit stops';
  String get overtakes => isRu ? 'Обгоны' : 'Overtakes';
  String get raceControl => isRu ? 'Гоночный контроль' : 'Race control';
  String get radio => isRu ? 'Рация' : 'Team radio';
  String get telemetry => isRu ? 'Телеметрия' : 'Telemetry';
  String get stints => isRu ? 'Стинты' : 'Stints';
  String get laps => isRu ? 'Круги' : 'Laps';
  String get standings => isRu ? 'Положение' : 'Standings';
  String get points => isRu ? 'Очки' : 'Points';
  String get upcoming => isRu ? 'Ближайшая' : 'Upcoming';
  String get current => isRu ? 'Текущая' : 'Current';
  String get past => isRu ? 'Прошедшие' : 'Past';
  String get airTemp => isRu ? 'Воздух' : 'Air';
  String get trackTemp => isRu ? 'Трасса' : 'Track';
  String get pressure => isRu ? 'Давление' : 'Pressure';
  String get wind => isRu ? 'Ветер' : 'Wind';
  String get rainfall => isRu ? 'Дождь' : 'Rainfall';
  String get language => isRu ? 'Язык' : 'Language';
  String get darkMode => isRu ? 'Тёмная тема' : 'Dark theme';
  String get noAudio => isRu ? 'Аудио недоступно' : 'No audio URL';
  String get status => isRu ? 'Статус' : 'Status';
  String get compound => isRu ? 'Состав' : 'Compound';
  String get searchHint => isRu ? 'Пилот, команда, этап' : 'Driver, team, meeting';
  String get sessionLive => 'LIVE';
  String get sessionFinished => isRu ? 'Завершено' : 'Finished';
  String get sessionUpcoming => isRu ? 'Скоро' : 'Upcoming';
  String get dataFresh => isRu ? 'Данные актуальны' : 'Data is current';
  String get dataFromSession => isRu ? 'Данные сессии' : 'Session data';
  String get predictedWinner => isRu ? 'Прогноз победителя' : 'Predicted winner';
  String get nextGrandPrix => isRu ? 'Следующий Гран-при' : 'Next Grand Prix';
  String get lastLeader => isRu ? 'Лидер сессии' : 'Session leader';
  String get circuit => isRu ? 'Трасса' : 'Circuit';
  String get timeToSession => isRu ? 'До сессии' : 'Until session';
  String get winModelHint => isRu
      ? 'Naive Bayes по сетке, чемпионату и последним гонкам. Не зависит от LIVE.'
      : 'Naive Bayes from grid, championship and recent races. Independent of LIVE.';
  String get carsOnTrack => isRu ? 'Машины по GPS' : 'Cars from GPS';
  String get trackOutlineOnly => isRu
      ? 'Схема по координатам сессии. Движение машин только при живых GPS.'
      : 'Layout from session coordinates. Car motion only with live GPS.';
  String get startFinish => isRu ? 'Старт / финиш' : 'Start / finish';
  String get lastLap => isRu ? 'Последний' : 'Last';
  String get bestLap => isRu ? 'Лучший' : 'Best';
  String get sector1 => 'S1';
  String get sector2 => 'S2';
  String get sector3 => 'S3';
  String get recentRace => isRu ? 'Последний этап' : 'Latest meeting';
  String get viewResults => isRu ? 'Все результаты' : 'Full results';
  String get predictedFor => isRu ? 'Прогноз на' : 'Prediction for';
  String get noWinModel => isRu
      ? 'Недостаточно истории для расчёта вероятности победы.'
      : 'Not enough history to calculate a win probability.';
  String get tapDriver => isRu ? 'Выберите пилота на карте или в таблице' : 'Select a driver on the map or table';
  String get weatherAir => isRu ? 'Воздух' : 'Air';
  String get mapLegend => isRu ? 'Пилоты на трассе' : 'Drivers on track';
  String get constructorsShort => isRu ? 'Кубок конструкторов' : 'Constructors';

  String get liveNow => 'LIVE';
  String get practice => isRu ? 'Практика' : 'Practice';
  String get qualifying => isRu ? 'Квалификация' : 'Qualifying';
  String get sprint => isRu ? 'Спринт' : 'Sprint';
  String get sprintQualifying => isRu ? 'Спринт-квалификация' : 'Sprint Qualifying';
  String get race => isRu ? 'Гонка' : 'Race';
  String get finished => isRu ? 'Завершено' : 'Finished';
  String get sessionGeneric => isRu ? 'Сессия' : 'Session';
  String get nextSession => isRu ? 'Следующая сессия' : 'Next session';
  String get updated => isRu ? 'Обновлено' : 'Updated';
  String get noCircuit => isRu ? 'Схема трассы недоступна' : 'Circuit layout unavailable';
  String get layoutFromLap => isRu
      ? 'Контур построен по кругу из координат OpenF1'
      : 'Outline traced from an OpenF1 location lap';
  String get layoutStatic => isRu
      ? 'Схема трассы. Машины не поставлены на карту: нет общей системы координат.'
      : 'Schematic layout. Cars are not plotted without a shared coordinate frame.';
  String get positionsSnapshot => isRu ? 'Позиции на момент' : 'Positions at';
  String get carPositionsUnavailable =>
      isRu ? 'Координаты машин недоступны' : 'Car coordinates unavailable';
  String get winForecast => isRu ? 'Прогноз победы в гонке' : 'Race win forecast';
  String get raceWin => isRu ? 'Вероятность победы в гонке' : 'Race win probability';
  String get noUpcomingGp =>
      isRu ? 'В календаре нет следующего Гран-при' : 'No upcoming Grand Prix is listed';
  String get formOutlook => isRu ? 'Оценка по текущей форме' : 'Outlook from current form';
  String get forecastEmpty => isRu
      ? 'Недостаточно данных, чтобы посчитать вероятность победы'
      : 'Not enough data to calculate a win probability';
  String get noEntryList => isRu
      ? 'Нет списка пилотов для расчёта'
      : 'No driver entry list is available for this forecast';
  String get basisGrid => isRu ? 'Стартовая решётка целевого Гран-при' : 'Starting grid of the target Grand Prix';
  String get basisChampionship => isRu
      ? 'Позиции чемпионата — решётка ещё не опубликована'
      : 'Championship positions — the grid is not published yet';
  String get basisResults => isRu
      ? 'Позиции последней сессии'
      : 'Latest session classification';
  String get basisNone => isRu ? 'Нет позиций для модели' : 'No position input for the model';
  String get wetFlag => isRu ? 'Мокрая сессия' : 'Wet session';
  String get dryFlag => isRu ? 'Сухая сессия' : 'Dry session';
  String get rainUnknown => isRu ? 'Дождь не задан' : 'Rain flag not set';
  String get racesUsed => isRu ? 'гонок в истории модели' : 'races in the model history';
  String get entryListFrom => isRu ? 'Состав' : 'Entry list';
  String get viewForecast => isRu ? 'Весь прогноз' : 'Full forecast';
  String get previousGp => isRu ? 'Прошлый Гран-при' : 'Previous Grand Prix';
  String get podium => isRu ? 'Первая тройка' : 'Top three';
  String get standingsChange => isRu ? 'Изменения в чемпионате' : 'Championship changes';
  String get s1 => 'S1';
  String get s2 => 'S2';
  String get s3 => 'S3';
  String get interval => isRu ? 'Интервал' : 'Interval';
  String get lapsShort => isRu ? 'Круги' : 'Laps';
  String get onTrack => isRu ? 'На трассе' : 'On track';
  String get retired => isRu ? 'Сход' : 'Retired';
  String get classified => isRu ? 'В протоколе' : 'Classified';
  String get selectDriver => isRu ? 'Выберите пилота на карте или в таблице' : 'Select a driver on the map or in the table';
  String get leader => isRu ? 'Лидер' : 'Leader';
  String get raceLaps => isRu ? 'Круги гонки' : 'Race laps';
  String get refresh => isRu ? 'Обновить' : 'Refresh';
  String get flags => isRu ? 'Флаги' : 'Flags';
  String get conditions => isRu ? 'Условия' : 'Conditions';
  String get notLive => isRu ? 'Сейчас нет активной сессии' : 'No session is in progress';
  String get gridView => isRu ? 'Решётка' : 'Grid';
  String get timingView => isRu ? 'Хронометраж' : 'Timing';
  String get calculatedAt => isRu ? 'Расчёт' : 'Calculated';
  String get numberSign => '№';
  String get teamCol => isRu ? 'Команда' : 'Team';
  String get forecastFor => isRu ? 'Следующий Гран-при' : 'Next Grand Prix';
  String get thisWeekend => isRu ? 'Текущий уик-энд' : 'This weekend';
  String get noDelta => isRu ? 'Сдвигов позиций нет' : 'No position changes recorded';

  String phaseLabel(String code) {
    switch (code) {
      case 'practice':
        return practice;
      case 'qualifying':
        return qualifying;
      case 'sprintQualifying':
        return sprintQualifying;
      case 'sprint':
        return sprint;
      case 'race':
        return race;
      case 'finished':
        return finished;
      case 'upcoming':
        return upcoming;
      default:
        return sessionGeneric;
    }
  }

  String basisLabel(String basis) {
    switch (basis) {
      case 'starting_grid':
        return basisGrid;
      case 'championship':
        return basisChampionship;
      case 'latest_results':
        return basisResults;
      default:
        return basisNone;
    }
  }

  String driverStatusLabel(String status) {
    switch (status) {
      case 'on_track':
        return onTrack;
      case 'retired':
        return retired;
      case 'dns':
        return 'DNS';
      case 'dsq':
        return 'DSQ';
      case 'classified':
        return classified;
      default:
        return '—';
    }
  }

  String featureLabel(String id) {
    switch (id) {
      case 'prior':
        return isRu ? 'Априори' : 'Prior';
      case 'pole':
        return pole;
      case 'grid':
        return gridPos;
      case 'rain':
        return rain;
      case 'form':
        return form;
      case 'team':
        return team;
      default:
        return id;
    }
  }
}
