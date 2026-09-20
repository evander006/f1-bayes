// Models matching OpenF1 API JSON fields: https://openf1.org/docs/

class Meeting {
  const Meeting({
    required this.circuitKey,
    this.circuitInfoUrl,
    this.circuitImage,
    required this.circuitShortName,
    this.circuitType,
    required this.countryCode,
    this.countryFlag,
    required this.countryKey,
    required this.countryName,
    required this.dateEnd,
    required this.dateStart,
    required this.gmtOffset,
    required this.isCancelled,
    required this.location,
    required this.meetingKey,
    required this.meetingName,
    required this.meetingOfficialName,
    required this.year,
  });

  final int circuitKey;
  final String? circuitInfoUrl;
  final String? circuitImage;
  final String circuitShortName;
  final String? circuitType;
  final String countryCode;
  final String? countryFlag;
  final int countryKey;
  final String countryName;
  final DateTime dateEnd;
  final DateTime dateStart;
  final String gmtOffset;
  final bool isCancelled;
  final String location;
  final int meetingKey;
  final String meetingName;
  final String meetingOfficialName;
  final int year;

  factory Meeting.fromJson(Map<String, dynamic> json) => Meeting(
        circuitKey: json['circuit_key'] as int,
        circuitInfoUrl: json['circuit_info_url'] as String?,
        circuitImage: json['circuit_image'] as String?,
        circuitShortName: json['circuit_short_name'] as String,
        circuitType: json['circuit_type'] as String?,
        countryCode: json['country_code'] as String,
        countryFlag: json['country_flag'] as String?,
        countryKey: json['country_key'] as int,
        countryName: json['country_name'] as String,
        dateEnd: DateTime.parse(json['date_end'] as String),
        dateStart: DateTime.parse(json['date_start'] as String),
        gmtOffset: json['gmt_offset'] as String,
        isCancelled: json['is_cancelled'] as bool? ?? false,
        location: json['location'] as String,
        meetingKey: json['meeting_key'] as int,
        meetingName: json['meeting_name'] as String,
        meetingOfficialName: json['meeting_official_name'] as String,
        year: json['year'] as int,
      );
}

class Session {
  const Session({
    required this.circuitKey,
    required this.circuitShortName,
    required this.countryCode,
    required this.countryKey,
    required this.countryName,
    required this.dateEnd,
    required this.dateStart,
    required this.gmtOffset,
    required this.isCancelled,
    required this.location,
    required this.meetingKey,
    required this.sessionKey,
    required this.sessionName,
    required this.sessionType,
    required this.year,
  });

  final int circuitKey;
  final String circuitShortName;
  final String countryCode;
  final int countryKey;
  final String countryName;
  final DateTime dateEnd;
  final DateTime dateStart;
  final String gmtOffset;
  final bool isCancelled;
  final String location;
  final int meetingKey;
  final int sessionKey;
  final String sessionName;
  final String sessionType;
  final int year;

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        circuitKey: json['circuit_key'] as int,
        circuitShortName: json['circuit_short_name'] as String,
        countryCode: json['country_code'] as String,
        countryKey: json['country_key'] as int,
        countryName: json['country_name'] as String,
        dateEnd: DateTime.parse(json['date_end'] as String),
        dateStart: DateTime.parse(json['date_start'] as String),
        gmtOffset: json['gmt_offset'] as String,
        isCancelled: json['is_cancelled'] as bool? ?? false,
        location: json['location'] as String,
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        sessionName: json['session_name'] as String,
        sessionType: json['session_type'] as String,
        year: json['year'] as int,
      );
}

class Driver {
  const Driver({
    required this.broadcastName,
    required this.driverNumber,
    required this.firstName,
    required this.fullName,
    this.headshotUrl,
    required this.lastName,
    required this.meetingKey,
    required this.nameAcronym,
    required this.sessionKey,
    required this.teamColour,
    required this.teamName,
  });

  final String broadcastName;
  final int driverNumber;
  final String firstName;
  final String fullName;
  final String? headshotUrl;
  final String lastName;
  final int meetingKey;
  final String nameAcronym;
  final int sessionKey;
  final String teamColour;
  final String teamName;

  String get shortName => '${firstName[0]}. $lastName';

  int get teamColorValue => int.parse('FF$teamColour', radix: 16);

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        broadcastName: json['broadcast_name'] as String,
        driverNumber: json['driver_number'] as int,
        firstName: json['first_name'] as String,
        fullName: json['full_name'] as String,
        headshotUrl: json['headshot_url'] as String?,
        lastName: json['last_name'] as String,
        meetingKey: json['meeting_key'] as int,
        nameAcronym: json['name_acronym'] as String,
        sessionKey: json['session_key'] as int,
        teamColour: json['team_colour'] as String,
        teamName: json['team_name'] as String,
      );
}

class Weather {
  const Weather({
    required this.meetingKey,
    required this.sessionKey,
    required this.date,
    required this.airTemperature,
    required this.trackTemperature,
    required this.humidity,
    required this.pressure,
    required this.rainfall,
    required this.windDirection,
    required this.windSpeed,
  });

  final int meetingKey;
  final int sessionKey;
  final DateTime date;
  final double airTemperature;
  final double trackTemperature;
  final double humidity;
  final double pressure;
  final int rainfall;
  final int windDirection;
  final double windSpeed;

  bool get isWet => rainfall > 0;

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        date: DateTime.parse(json['date'] as String),
        airTemperature: (json['air_temperature'] as num).toDouble(),
        trackTemperature: (json['track_temperature'] as num).toDouble(),
        humidity: (json['humidity'] as num).toDouble(),
        pressure: (json['pressure'] as num).toDouble(),
        rainfall: (json['rainfall'] as num).toInt(),
        windDirection: json['wind_direction'] as int,
        windSpeed: (json['wind_speed'] as num).toDouble(),
      );
}

class SessionResult {
  const SessionResult({
    required this.dnf,
    required this.dns,
    required this.dsq,
    required this.driverNumber,
    this.duration,
    this.qualifyingDurations,
    this.gapToLeader,
    this.numberOfLaps,
    required this.meetingKey,
    required this.position,
    required this.sessionKey,
  });

  final bool dnf;
  final bool dns;
  final bool dsq;
  final int driverNumber;
  final double? duration;
  final List<double?>? qualifyingDurations;
  final String? gapToLeader;
  final int? numberOfLaps;
  final int meetingKey;
  final int position;
  final int sessionKey;

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    final rawDuration = json['duration'];
    double? duration;
    List<double?>? qualifyingDurations;
    if (rawDuration is List) {
      qualifyingDurations = rawDuration
          .map((e) => e == null ? null : (e as num).toDouble())
          .toList();
    } else if (rawDuration is num) {
      duration = rawDuration.toDouble();
    }

    final rawGap = json['gap_to_leader'];
    return SessionResult(
      dnf: json['dnf'] as bool? ?? false,
      dns: json['dns'] as bool? ?? false,
      dsq: json['dsq'] as bool? ?? false,
      driverNumber: json['driver_number'] as int,
      duration: duration,
      qualifyingDurations: qualifyingDurations,
      gapToLeader: rawGap?.toString(),
      numberOfLaps: json['number_of_laps'] as int?,
      meetingKey: json['meeting_key'] as int,
      position: json['position'] as int,
      sessionKey: json['session_key'] as int,
    );
  }
}

class StartingGrid {
  const StartingGrid({
    required this.position,
    required this.driverNumber,
    this.lapDuration,
    required this.meetingKey,
    required this.sessionKey,
  });

  final int position;
  final int driverNumber;
  final double? lapDuration;
  final int meetingKey;
  final int sessionKey;

  bool get isPole => position == 1;

  factory StartingGrid.fromJson(Map<String, dynamic> json) => StartingGrid(
        position: json['position'] as int,
        driverNumber: json['driver_number'] as int,
        lapDuration: (json['lap_duration'] as num?)?.toDouble(),
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
      );
}

class Position {
  const Position({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.date,
    required this.position,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final DateTime date;
  final int position;

  factory Position.fromJson(Map<String, dynamic> json) => Position(
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        driverNumber: json['driver_number'] as int,
        date: DateTime.parse(json['date'] as String),
        position: json['position'] as int,
      );
}

class Interval {
  const Interval({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.date,
    this.gapToLeader,
    this.interval,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final DateTime date;
  final double? gapToLeader;
  final double? interval;

  factory Interval.fromJson(Map<String, dynamic> json) => Interval(
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        driverNumber: json['driver_number'] as int,
        date: DateTime.parse(json['date'] as String),
        gapToLeader: (json['gap_to_leader'] as num?)?.toDouble(),
        interval: (json['interval'] as num?)?.toDouble(),
      );
}

class Lap {
  const Lap({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.lapNumber,
    this.lapDuration,
    this.durationSector1,
    this.durationSector2,
    this.durationSector3,
    this.isPitOutLap = false,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final int lapNumber;
  final double? lapDuration;
  final double? durationSector1;
  final double? durationSector2;
  final double? durationSector3;
  final bool isPitOutLap;

  factory Lap.fromJson(Map<String, dynamic> json) => Lap(
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        driverNumber: json['driver_number'] as int,
        lapNumber: json['lap_number'] as int,
        lapDuration: (json['lap_duration'] as num?)?.toDouble(),
        durationSector1: (json['duration_sector_1'] as num?)?.toDouble(),
        durationSector2: (json['duration_sector_2'] as num?)?.toDouble(),
        durationSector3: (json['duration_sector_3'] as num?)?.toDouble(),
        isPitOutLap: json['is_pit_out_lap'] as bool? ?? false,
      );
}

class Stint {
  const Stint({
    required this.meetingKey,
    required this.sessionKey,
    required this.driverNumber,
    required this.stintNumber,
    required this.lapStart,
    this.lapEnd,
    required this.compound,
    required this.tyreAgeAtStart,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final int stintNumber;
  final int lapStart;
  final int? lapEnd;
  final String compound;
  final int tyreAgeAtStart;

  factory Stint.fromJson(Map<String, dynamic> json) => Stint(
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        driverNumber: json['driver_number'] as int,
        stintNumber: json['stint_number'] as int,
        lapStart: json['lap_start'] as int,
        lapEnd: json['lap_end'] as int?,
        compound: json['compound'] as String,
        tyreAgeAtStart: json['tyre_age_at_start'] as int,
      );
}

class CarData {
  const CarData({
    required this.brake,
    required this.date,
    required this.driverNumber,
    required this.drs,
    required this.meetingKey,
    required this.nGear,
    required this.rpm,
    required this.sessionKey,
    required this.speed,
    required this.throttle,
  });

  final int brake;
  final DateTime date;
  final int driverNumber;
  final int drs;
  final int meetingKey;
  final int nGear;
  final int rpm;
  final int sessionKey;
  final int speed;
  final int throttle;

  factory CarData.fromJson(Map<String, dynamic> json) => CarData(
        brake: json['brake'] as int,
        date: DateTime.parse(json['date'] as String),
        driverNumber: json['driver_number'] as int,
        drs: json['drs'] as int,
        meetingKey: json['meeting_key'] as int,
        nGear: json['n_gear'] as int,
        rpm: json['rpm'] as int,
        sessionKey: json['session_key'] as int,
        speed: json['speed'] as int,
        throttle: json['throttle'] as int,
      );
}

class ChampionshipDriver {
  const ChampionshipDriver({
    required this.driverNumber,
    required this.meetingKey,
    required this.pointsCurrent,
    required this.pointsStart,
    required this.positionCurrent,
    required this.positionStart,
    required this.sessionKey,
  });

  final int driverNumber;
  final int meetingKey;
  final double pointsCurrent;
  final double pointsStart;
  final int positionCurrent;
  final int positionStart;
  final int sessionKey;

  factory ChampionshipDriver.fromJson(Map<String, dynamic> json) =>
      ChampionshipDriver(
        driverNumber: json['driver_number'] as int,
        meetingKey: json['meeting_key'] as int,
        pointsCurrent: (json['points_current'] as num).toDouble(),
        pointsStart: (json['points_start'] as num).toDouble(),
        positionCurrent: json['position_current'] as int,
        positionStart: json['position_start'] as int,
        sessionKey: json['session_key'] as int,
      );
}

class LocationPoint {
  const LocationPoint({
    required this.date,
    required this.driverNumber,
    required this.meetingKey,
    required this.sessionKey,
    required this.x,
    required this.y,
    required this.z,
  });

  final DateTime date;
  final int driverNumber;
  final int meetingKey;
  final int sessionKey;
  final double x;
  final double y;
  final double z;

  factory LocationPoint.fromJson(Map<String, dynamic> json) => LocationPoint(
        date: DateTime.parse(json['date'] as String),
        driverNumber: json['driver_number'] as int,
        meetingKey: json['meeting_key'] as int,
        sessionKey: json['session_key'] as int,
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        z: (json['z'] as num).toDouble(),
      );
}
