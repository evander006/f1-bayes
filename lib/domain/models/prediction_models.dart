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
    required this.interval,
    required this.stint,
    this.bestLap,
  });

  final Driver driver;
  final Position position;
  final Interval interval;
  final Stint stint;
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
    required this.hitRateDelta,
    required this.brierDelta,
    required this.byRace,
  });

  final double hitRate;
  final double brierScore;
  final double top3Coverage;
  final double hitRateDelta;
  final double brierDelta;
  final List<RaceAccuracy> byRace;
}

class MockSnapshot {
  const MockSnapshot({
    required this.meeting,
    required this.raceSession,
    required this.qualifyingSession,
    required this.drivers,
    required this.weather,
    required this.startingGrid,
    required this.qualifyingResults,
    required this.predictions,
    required this.classification,
    required this.leaderCarData,
    required this.leaderLap,
    required this.championship,
    required this.accuracy,
    required this.trackLocations,
    required this.totalLaps,
    required this.circuitLengthKm,
  });

  final Meeting meeting;
  final Session raceSession;
  final Session qualifyingSession;
  final List<Driver> drivers;
  final Weather weather;
  final List<StartingGrid> startingGrid;
  final List<SessionResult> qualifyingResults;
  final List<DriverPrediction> predictions;
  final List<LiveClassificationRow> classification;
  final CarData leaderCarData;
  final Lap leaderLap;
  final ChampionshipDriver championship;
  final ModelAccuracy accuracy;
  final List<LocationPoint> trackLocations;
  final int totalLaps;
  final double circuitLengthKm;

  Driver driverByNumber(int number) =>
      drivers.firstWhere((d) => d.driverNumber == number);

  DriverPrediction get favorite => predictions.first;

  LiveClassificationRow get leader => classification.first;

  StartingGrid get pole =>
      startingGrid.firstWhere((g) => g.position == 1);
}
