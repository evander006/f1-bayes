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
  String get speed => isRu ? 'Скорость' : 'Speed';
  String get gap => isRu ? 'Отрыв' : 'Gap';
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

  String featureLabel(String id) {
    switch (id) {
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
