import '../models/openf1_models.dart';
import '../../domain/models/prediction_models.dart';

const _meetingKey = 1258;
const _raceKey = 9901;
const _qualiKey = 9900;
const _now = '2025-05-25T13:22:00+00:00';

class MockOpenF1 {
  MockOpenF1._();

  static final snapshot = _build();

  static MockSnapshot _build() {
    final meeting = Meeting(
      circuitKey: 6,
      circuitImage:
          'https://media.formula1.com/content/dam/fom-website/2018-redesign-assets/Track%20icons%204x3/Monaco%20carbon.png',
      circuitShortName: 'Monaco',
      circuitType: 'Temporary - Street',
      countryCode: 'MCO',
      countryFlag:
          'https://media.formula1.com/content/dam/fom-website/2018-redesign-assets/Flags%2016x9/monaco-flag.png',
      countryKey: 114,
      countryName: 'Monaco',
      dateEnd: DateTime.parse('2025-05-25T15:00:00+00:00'),
      dateStart: DateTime.parse('2025-05-23T11:30:00+00:00'),
      gmtOffset: '02:00:00',
      isCancelled: false,
      location: 'Monte Carlo',
      meetingKey: _meetingKey,
      meetingName: 'Monaco Grand Prix',
      meetingOfficialName:
          'FORMULA 1 GRAND PRIX DE MONACO 2025',
      year: 2025,
    );

    final race = Session(
      circuitKey: 6,
      circuitShortName: 'Monaco',
      countryCode: 'MCO',
      countryKey: 114,
      countryName: 'Monaco',
      dateEnd: DateTime.parse('2025-05-25T16:00:00+00:00'),
      dateStart: DateTime.parse('2025-05-25T13:00:00+00:00'),
      gmtOffset: '02:00:00',
      isCancelled: false,
      location: 'Monte Carlo',
      meetingKey: _meetingKey,
      sessionKey: _raceKey,
      sessionName: 'Race',
      sessionType: 'Race',
      year: 2025,
    );

    final quali = Session(
      circuitKey: 6,
      circuitShortName: 'Monaco',
      countryCode: 'MCO',
      countryKey: 114,
      countryName: 'Monaco',
      dateEnd: DateTime.parse('2025-05-24T15:00:00+00:00'),
      dateStart: DateTime.parse('2025-05-24T14:00:00+00:00'),
      gmtOffset: '02:00:00',
      isCancelled: false,
      location: 'Monte Carlo',
      meetingKey: _meetingKey,
      sessionKey: _qualiKey,
      sessionName: 'Qualifying',
      sessionType: 'Qualifying',
      year: 2025,
    );

    final drivers = <Driver>[
      _driver(16, 'Charles', 'Leclerc', 'LEC', 'Ferrari', 'E80020'),
      _driver(4, 'Lando', 'Norris', 'NOR', 'McLaren', 'FF8000'),
      _driver(81, 'Oscar', 'Piastri', 'PIA', 'McLaren', 'FF8000'),
      _driver(1, 'Max', 'Verstappen', 'VER', 'Red Bull Racing', '3671C6'),
      _driver(44, 'Lewis', 'Hamilton', 'HAM', 'Ferrari', 'E80020'),
      _driver(63, 'George', 'Russell', 'RUS', 'Mercedes', '27F4D2'),
      _driver(12, 'Kimi', 'Antonelli', 'ANT', 'Mercedes', '27F4D2'),
      _driver(23, 'Alexander', 'Albon', 'ALB', 'Williams', '64C4FF'),
      _driver(55, 'Carlos', 'Sainz', 'SAI', 'Williams', '64C4FF'),
      _driver(14, 'Fernando', 'Alonso', 'ALO', 'Aston Martin', '229971'),
    ];

    Driver d(int n) => drivers.firstWhere((e) => e.driverNumber == n);

    final weather = Weather(
      meetingKey: _meetingKey,
      sessionKey: _raceKey,
      date: DateTime.parse(_now),
      airTemperature: 22,
      trackTemperature: 34.6,
      humidity: 58,
      pressure: 1012,
      rainfall: 0,
      windDirection: 140,
      windSpeed: 2.4,
    );

    const gridTimes = {
      16: 70.265,
      4: 70.412,
      81: 70.478,
      1: 70.591,
      44: 70.733,
      63: 70.881,
      12: 71.103,
      23: 71.154,
      55: 71.281,
      14: 71.487,
    };

    final grid = [
      for (final entry in gridTimes.entries.toList().asMap().entries)
        StartingGrid(
          position: entry.key + 1,
          driverNumber: entry.value.key,
          lapDuration: entry.value.value,
          meetingKey: _meetingKey,
          sessionKey: _raceKey,
        ),
    ];

    final qualiResults = [
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 16,
        qualifyingDurations: const [71.264, 70.612, 70.265],
        meetingKey: _meetingKey,
        position: 1,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 4,
        qualifyingDurations: const [71.318, 70.701, 70.412],
        meetingKey: _meetingKey,
        position: 2,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 81,
        qualifyingDurations: const [71.391, 70.748, 70.478],
        meetingKey: _meetingKey,
        position: 3,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 1,
        qualifyingDurations: const [71.412, 70.812, 70.591],
        meetingKey: _meetingKey,
        position: 4,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 44,
        qualifyingDurations: const [71.508, 70.933, 70.733],
        meetingKey: _meetingKey,
        position: 5,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 63,
        qualifyingDurations: const [71.554, 71.012, 70.881],
        meetingKey: _meetingKey,
        position: 6,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 12,
        qualifyingDurations: const [71.603, 71.154, 71.103],
        meetingKey: _meetingKey,
        position: 7,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 23,
        qualifyingDurations: const [71.641, 71.203, 71.154],
        meetingKey: _meetingKey,
        position: 8,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 55,
        qualifyingDurations: const [71.733, 71.281, null],
        meetingKey: _meetingKey,
        position: 9,
        sessionKey: _qualiKey,
      ),
      SessionResult(
        dnf: false,
        dns: false,
        dsq: false,
        driverNumber: 14,
        qualifyingDurations: const [71.812, 71.487, null],
        meetingKey: _meetingKey,
        position: 10,
        sessionKey: _qualiKey,
      ),
    ];

    const probs = {
      16: 0.324,
      4: 0.241,
      81: 0.187,
      1: 0.136,
      44: 0.078,
      63: 0.012,
      12: 0.008,
      23: 0.006,
      55: 0.005,
      14: 0.003,
    };

    const featureSets = {
      16: [0.92, 0.88, 0.41, 0.74, 0.81],
      4: [0.71, 0.76, 0.38, 0.86, 0.84],
      81: [0.64, 0.70, 0.36, 0.81, 0.84],
      1: [0.48, 0.55, 0.62, 0.79, 0.72],
      44: [0.40, 0.44, 0.39, 0.61, 0.81],
    };

    List<FeatureContribution> featuresFor(int n) {
      final raw = featureSets[n] ?? const [0.22, 0.28, 0.31, 0.34, 0.40];
      const ids = ['pole', 'grid', 'rain', 'form', 'team'];
      return [
        for (var i = 0; i < ids.length; i++)
          FeatureContribution(id: ids[i], weight: raw[i]),
      ];
    }

    final predictions = [
      for (final n in probs.keys)
        DriverPrediction(
          driver: d(n),
          winProbability: probs[n]!,
          grid: grid.firstWhere((g) => g.driverNumber == n),
          features: featuresFor(n),
          qualifying: qualiResults.firstWhere((q) => q.driverNumber == n),
        ),
    ]..sort((a, b) => b.winProbability.compareTo(a.winProbability));

    const liveOrder = [16, 4, 81, 1, 44, 63, 12, 23, 55, 14];
    const gaps = [0.0, 2.381, 4.872, 6.113, 11.358, 14.201, 18.650, 21.412, 24.880, 28.104];
    const compounds = [
      'SOFT',
      'SOFT',
      'MEDIUM',
      'SOFT',
      'HARD',
      'MEDIUM',
      'MEDIUM',
      'HARD',
      'MEDIUM',
      'HARD',
    ];

    final classification = [
      for (var i = 0; i < liveOrder.length; i++)
        LiveClassificationRow(
          driver: d(liveOrder[i]),
          position: Position(
            meetingKey: _meetingKey,
            sessionKey: _raceKey,
            driverNumber: liveOrder[i],
            date: DateTime.parse(_now),
            position: i + 1,
          ),
          interval: Interval(
            meetingKey: _meetingKey,
            sessionKey: _raceKey,
            driverNumber: liveOrder[i],
            date: DateTime.parse(_now),
            gapToLeader: gaps[i],
            interval: i == 0 ? 0 : gaps[i] - gaps[i - 1],
          ),
          stint: Stint(
            meetingKey: _meetingKey,
            sessionKey: _raceKey,
            driverNumber: liveOrder[i],
            stintNumber: 2,
            lapStart: 18,
            lapEnd: 32,
            compound: compounds[i],
            tyreAgeAtStart: 2,
          ),
          bestLap: Lap(
            meetingKey: _meetingKey,
            sessionKey: _raceKey,
            driverNumber: liveOrder[i],
            lapNumber: 21,
            lapDuration: 73.2 + i * 0.18,
          ),
        ),
    ];

    final leaderCar = CarData(
      brake: 0,
      date: DateTime.parse(_now),
      driverNumber: 16,
      drs: 8,
      meetingKey: _meetingKey,
      nGear: 6,
      rpm: 11240,
      sessionKey: _raceKey,
      speed: 312,
      throttle: 98,
    );

    final leaderLap = Lap(
      meetingKey: _meetingKey,
      sessionKey: _raceKey,
      driverNumber: 16,
      lapNumber: 32,
      lapDuration: 73.411,
      durationSector1: 18.2,
      durationSector2: 34.1,
      durationSector3: 21.1,
    );

    final championship = const ChampionshipDriver(
      driverNumber: 16,
      meetingKey: _meetingKey,
      pointsCurrent: 104,
      pointsStart: 79,
      positionCurrent: 3,
      positionStart: 4,
      sessionKey: _raceKey,
    );

    Meeting past(int key, String name, String country, String code, DateTime start) {
      return Meeting(
        circuitKey: key,
        circuitShortName: name,
        countryCode: code,
        countryKey: key,
        countryName: country,
        dateEnd: start.add(const Duration(hours: 2)),
        dateStart: start,
        gmtOffset: '00:00:00',
        isCancelled: false,
        location: name,
        meetingKey: key,
        meetingName: '$name Grand Prix',
        meetingOfficialName: '$name Grand Prix',
        year: 2025,
      );
    }

    final accuracy = ModelAccuracy(
      hitRate: 0.723,
      brierScore: 0.178,
      top3Coverage: 0.685,
      hitRateDelta: 0.06,
      brierDelta: -0.12,
      byRace: [
        RaceAccuracy(
          meeting: past(1254, 'Bahrain', 'Bahrain', 'BHR', DateTime(2025, 3, 16)),
          predictedWinner: d(16),
          actualWinner: d(4),
          top3Predicted: [d(16), d(4), d(1)],
          brierScore: 0.142,
          hit: false,
        ),
        RaceAccuracy(
          meeting: past(1255, 'Jeddah', 'Saudi Arabia', 'SAU', DateTime(2025, 4, 6)),
          predictedWinner: d(4),
          actualWinner: d(4),
          top3Predicted: [d(4), d(81), d(16)],
          brierScore: 0.091,
          hit: true,
        ),
        RaceAccuracy(
          meeting: past(1256, 'Suzuka', 'Japan', 'JPN', DateTime(2025, 4, 6)),
          predictedWinner: d(1),
          actualWinner: d(1),
          top3Predicted: [d(1), d(4), d(81)],
          brierScore: 0.118,
          hit: true,
        ),
        RaceAccuracy(
          meeting: past(1257, 'Shanghai', 'China', 'CHN', DateTime(2025, 4, 21)),
          predictedWinner: d(4),
          actualWinner: d(81),
          top3Predicted: [d(4), d(81), d(16)],
          brierScore: 0.187,
          hit: false,
        ),
      ],
    );

    final locations = <LocationPoint>[
      LocationPoint(
        date: DateTime.parse(_now),
        driverNumber: 16,
        meetingKey: _meetingKey,
        sessionKey: _raceKey,
        x: 0.78,
        y: 0.22,
        z: 0,
      ),
      LocationPoint(
        date: DateTime.parse(_now),
        driverNumber: 4,
        meetingKey: _meetingKey,
        sessionKey: _raceKey,
        x: 0.62,
        y: 0.38,
        z: 0,
      ),
      LocationPoint(
        date: DateTime.parse(_now),
        driverNumber: 81,
        meetingKey: _meetingKey,
        sessionKey: _raceKey,
        x: 0.48,
        y: 0.58,
        z: 0,
      ),
      LocationPoint(
        date: DateTime.parse(_now),
        driverNumber: 1,
        meetingKey: _meetingKey,
        sessionKey: _raceKey,
        x: 0.28,
        y: 0.70,
        z: 0,
      ),
    ];

    return MockSnapshot(
      meeting: meeting,
      raceSession: race,
      qualifyingSession: quali,
      drivers: drivers,
      weather: weather,
      startingGrid: grid,
      qualifyingResults: qualiResults,
      predictions: predictions,
      classification: classification,
      leaderCarData: leaderCar,
      leaderLap: leaderLap,
      championship: championship,
      accuracy: accuracy,
      trackLocations: locations,
      totalLaps: 78,
      circuitLengthKm: 3.337,
    );
  }

  static Driver _driver(
    int number,
    String first,
    String last,
    String acr,
    String team,
    String colour,
  ) {
    final code = '${first.substring(0, 3).toUpperCase()}${last.substring(0, 3).toUpperCase()}01';
    return Driver(
      broadcastName: '${first[0]} ${last.toUpperCase()}',
      driverNumber: number,
      firstName: first,
      fullName: '$first ${last.toUpperCase()}',
      headshotUrl:
          'https://media.formula1.com/d_driver_fallback_image.png/content/dam/fom-website/drivers/${first[0]}/${code}_${first}_$last/${acr.toLowerCase()}01.png',
      lastName: last,
      meetingKey: _meetingKey,
      nameAcronym: acr,
      sessionKey: _raceKey,
      teamColour: colour,
      teamName: team,
    );
  }
}
