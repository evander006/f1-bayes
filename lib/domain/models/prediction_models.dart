import '../../data/models/openf1_models.dart';

class FeatureContribution {
  const FeatureContribution({
    required this.id,
    required this.weight,
  });

  final String id;
  final double weight;
}

class DriverPrediction {
  const DriverPrediction({
    required this.driver,
    required this.winProbability,
    required this.grid,
    required this.features,
    this.qualifying,
  });

  final Driver driver;
  final double winProbability;
  final StartingGrid grid;
  final List<FeatureContribution> features;
  final SessionResult? qualifying;
}

class LiveClassificationRow {
  const LiveClassificationRow({
    required this.driver,
    required this.position,
    this.interval,
    this.stint,
    this.bestLap,
  });

  final Driver driver;
  final int position;
  final Interval? interval;
  final Stint? stint;
  final Lap? bestLap;
}

class RaceAccuracy {
  const RaceAccuracy({
    required this.meeting,
    required this.predictedWinner,
    required this.actualWinner,
    required this.top3Predicted,
    required this.brierScore,
    required this.hit,
  });

  final Meeting meeting;
  final Driver predictedWinner;
  final Driver actualWinner;
  final List<Driver> top3Predicted;
  final double brierScore;
  final bool hit;
}

class ModelAccuracy {
  const ModelAccuracy({
    required this.hitRate,
    required this.brierScore,
    required this.top3Coverage,
    required this.byRace,
  });

  final double hitRate;
  final double brierScore;
  final double top3Coverage;
  final List<RaceAccuracy> byRace;
}
