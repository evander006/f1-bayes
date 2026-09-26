import '../json_parse.dart';

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
        circuitKey: asInt(json['circuit_key']) ?? 0,
        circuitInfoUrl: asString(json['circuit_info_url']),
        circuitImage: asString(json['circuit_image']),
        circuitShortName: asString(json['circuit_short_name']) ?? '',
        circuitType: asString(json['circuit_type']),
        countryCode: asString(json['country_code']) ?? '',
        countryFlag: asString(json['country_flag']),
        countryKey: asInt(json['country_key']) ?? 0,
        countryName: asString(json['country_name']) ?? '',
        dateEnd: asDate(json['date_end']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        dateStart: asDate(json['date_start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        gmtOffset: asString(json['gmt_offset']) ?? '',
        isCancelled: asBool(json['is_cancelled']),
        location: asString(json['location']) ?? '',
        meetingKey: asInt(json['meeting_key']) ?? 0,
        meetingName: asString(json['meeting_name']) ?? '',
        meetingOfficialName: asString(json['meeting_official_name']) ?? '',
        year: asInt(json['year']) ?? 0,
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

  bool get isRace => sessionName == 'Race' || sessionType == 'Race';
  bool get isQualifying =>
      sessionName.contains('Qualifying') || sessionType.contains('Qualifying');

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        circuitKey: asInt(json['circuit_key']) ?? 0,
        circuitShortName: asString(json['circuit_short_name']) ?? '',
        countryCode: asString(json['country_code']) ?? '',
        countryKey: asInt(json['country_key']) ?? 0,
        countryName: asString(json['country_name']) ?? '',
        dateEnd: asDate(json['date_end']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        dateStart: asDate(json['date_start']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        gmtOffset: asString(json['gmt_offset']) ?? '',
        isCancelled: asBool(json['is_cancelled']),
        location: asString(json['location']) ?? '',
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        sessionName: asString(json['session_name']) ?? '',
        sessionType: asString(json['session_type']) ?? '',
        year: asInt(json['year']) ?? 0,
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
    this.teamColour,
    required this.teamName,
    this.countryCode,
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
  final String? teamColour;
  final String teamName;
  final String? countryCode;

  String get shortName {
    if (firstName.isEmpty) return lastName;
    return '${firstName[0]}. $lastName';
  }

  int get teamColorValue => parseTeamColorValue(teamColour);

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        broadcastName: asString(json['broadcast_name']) ?? '',
        driverNumber: asInt(json['driver_number']) ?? 0,
        firstName: asString(json['first_name']) ?? '',
        fullName: asString(json['full_name']) ?? '',
        headshotUrl: asString(json['headshot_url']),
        lastName: asString(json['last_name']) ?? '',
        meetingKey: asInt(json['meeting_key']) ?? 0,
        nameAcronym: asString(json['name_acronym']) ?? '',
        sessionKey: asInt(json['session_key']) ?? 0,
        teamColour: asString(json['team_colour']),
        teamName: asString(json['team_name']) ?? '',
        countryCode: asString(json['country_code']),
      );
}

class Weather {
  const Weather({
    required this.meetingKey,
    required this.sessionKey,
    required this.date,
    this.airTemperature,
    this.trackTemperature,
    this.humidity,
    this.pressure,
    this.rainfall,
    this.windDirection,
    this.windSpeed,
  });

  final int meetingKey;
  final int sessionKey;
  final DateTime date;
  final double? airTemperature;
  final double? trackTemperature;
  final double? humidity;
  final double? pressure;
  final int? rainfall;
  final int? windDirection;
  final double? windSpeed;

  bool get isWet => (rainfall ?? 0) > 0;

  factory Weather.fromJson(Map<String, dynamic> json) => Weather(
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        airTemperature: asDouble(json['air_temperature']),
        trackTemperature: asDouble(json['track_temperature']),
        humidity: asDouble(json['humidity']),
        pressure: asDouble(json['pressure']),
        rainfall: asInt(json['rainfall']),
        windDirection: asInt(json['wind_direction']),
        windSpeed: asDouble(json['wind_speed']),
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
      qualifyingDurations = rawDuration.map(asDouble).toList();
    } else {
      duration = asDouble(rawDuration);
    }

    return SessionResult(
      dnf: asBool(json['dnf']),
      dns: asBool(json['dns']),
      dsq: asBool(json['dsq']),
      driverNumber: asInt(json['driver_number']) ?? 0,
      duration: duration,
      qualifyingDurations: qualifyingDurations,
      gapToLeader: json['gap_to_leader']?.toString(),
      numberOfLaps: asInt(json['number_of_laps']),
      meetingKey: asInt(json['meeting_key']) ?? 0,
      position: asInt(json['position']) ?? 0,
      sessionKey: asInt(json['session_key']) ?? 0,
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
        position: asInt(json['position']) ?? 0,
        driverNumber: asInt(json['driver_number']) ?? 0,
        lapDuration: asDouble(json['lap_duration']),
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
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
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        driverNumber: asInt(json['driver_number']) ?? 0,
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        position: asInt(json['position']) ?? 0,
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
    this.gapToLeaderLabel,
    this.intervalLabel,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final DateTime date;
  final double? gapToLeader;
  final double? interval;
  final String? gapToLeaderLabel;
  final String? intervalLabel;

  factory Interval.fromJson(Map<String, dynamic> json) => Interval(
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        driverNumber: asInt(json['driver_number']) ?? 0,
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        gapToLeader: asGapSeconds(json['gap_to_leader']),
        interval: asGapSeconds(json['interval']),
        gapToLeaderLabel: asGapLabel(json['gap_to_leader']),
        intervalLabel: asGapLabel(json['interval']),
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
    this.i1Speed,
    this.i2Speed,
    this.stSpeed,
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
  final double? i1Speed;
  final double? i2Speed;
  final double? stSpeed;

  factory Lap.fromJson(Map<String, dynamic> json) => Lap(
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        driverNumber: asInt(json['driver_number']) ?? 0,
        lapNumber: asInt(json['lap_number']) ?? 0,
        lapDuration: asDouble(json['lap_duration']),
        durationSector1: asDouble(json['duration_sector_1']),
        durationSector2: asDouble(json['duration_sector_2']),
        durationSector3: asDouble(json['duration_sector_3']),
        isPitOutLap: asBool(json['is_pit_out_lap']),
        i1Speed: asDouble(json['i1_speed']),
        i2Speed: asDouble(json['i2_speed']),
        stSpeed: asDouble(json['st_speed']),
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
    this.compound,
    this.tyreAgeAtStart,
  });

  final int meetingKey;
  final int sessionKey;
  final int driverNumber;
  final int stintNumber;
  final int lapStart;
  final int? lapEnd;
  final String? compound;
  final int? tyreAgeAtStart;

  factory Stint.fromJson(Map<String, dynamic> json) => Stint(
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        driverNumber: asInt(json['driver_number']) ?? 0,
        stintNumber: asInt(json['stint_number']) ?? 0,
        lapStart: asInt(json['lap_start']) ?? 0,
        lapEnd: asInt(json['lap_end']),
        compound: asString(json['compound']),
        tyreAgeAtStart: asInt(json['tyre_age_at_start']),
      );
}

class CarData {
  const CarData({
    this.brake,
    required this.date,
    required this.driverNumber,
    this.drs,
    required this.meetingKey,
    this.nGear,
    this.rpm,
    required this.sessionKey,
    this.speed,
    this.throttle,
  });

  final int? brake;
  final DateTime date;
  final int driverNumber;
  final int? drs;
  final int meetingKey;
  final int? nGear;
  final int? rpm;
  final int sessionKey;
  final int? speed;
  final int? throttle;

  factory CarData.fromJson(Map<String, dynamic> json) => CarData(
        brake: asInt(json['brake']),
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        driverNumber: asInt(json['driver_number']) ?? 0,
        drs: asInt(json['drs']),
        meetingKey: asInt(json['meeting_key']) ?? 0,
        nGear: asInt(json['n_gear']),
        rpm: asInt(json['rpm']),
        sessionKey: asInt(json['session_key']) ?? 0,
        speed: asInt(json['speed']),
        throttle: asInt(json['throttle']),
      );
}

class ChampionshipDriver {
  const ChampionshipDriver({
    required this.driverNumber,
    required this.meetingKey,
    this.pointsCurrent,
    this.pointsStart,
    this.positionCurrent,
    this.positionStart,
    required this.sessionKey,
  });

  final int driverNumber;
  final int meetingKey;
  final double? pointsCurrent;
  final double? pointsStart;
  final int? positionCurrent;
  final int? positionStart;
  final int sessionKey;

  factory ChampionshipDriver.fromJson(Map<String, dynamic> json) =>
      ChampionshipDriver(
        driverNumber: asInt(json['driver_number']) ?? 0,
        meetingKey: asInt(json['meeting_key']) ?? 0,
        pointsCurrent: asDouble(json['points_current']),
        pointsStart: asDouble(json['points_start']),
        positionCurrent: asInt(json['position_current']),
        positionStart: asInt(json['position_start']),
        sessionKey: asInt(json['session_key']) ?? 0,
      );
}

class ChampionshipTeam {
  const ChampionshipTeam({
    required this.teamName,
    required this.meetingKey,
    this.pointsCurrent,
    this.pointsStart,
    this.positionCurrent,
    this.positionStart,
    required this.sessionKey,
  });

  final String teamName;
  final int meetingKey;
  final double? pointsCurrent;
  final double? pointsStart;
  final int? positionCurrent;
  final int? positionStart;
  final int sessionKey;

  factory ChampionshipTeam.fromJson(Map<String, dynamic> json) =>
      ChampionshipTeam(
        teamName: asString(json['team_name']) ?? '',
        meetingKey: asInt(json['meeting_key']) ?? 0,
        pointsCurrent: asDouble(json['points_current']),
        pointsStart: asDouble(json['points_start']),
        positionCurrent: asInt(json['position_current']),
        positionStart: asInt(json['position_start']),
        sessionKey: asInt(json['session_key']) ?? 0,
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
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        driverNumber: asInt(json['driver_number']) ?? 0,
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        x: asDouble(json['x']) ?? 0,
        y: asDouble(json['y']) ?? 0,
        z: asDouble(json['z']) ?? 0,
      );
}

class PitStop {
  const PitStop({
    required this.date,
    required this.driverNumber,
    required this.lapNumber,
    this.pitDuration,
    required this.meetingKey,
    required this.sessionKey,
  });

  final DateTime date;
  final int driverNumber;
  final int lapNumber;
  final double? pitDuration;
  final int meetingKey;
  final int sessionKey;

  factory PitStop.fromJson(Map<String, dynamic> json) => PitStop(
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        driverNumber: asInt(json['driver_number']) ?? 0,
        lapNumber: asInt(json['lap_number']) ?? 0,
        pitDuration: asDouble(json['pit_duration']),
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
      );
}

class Overtake {
  const Overtake({
    required this.date,
    required this.meetingKey,
    required this.sessionKey,
    required this.overtakingDriverNumber,
    required this.overtakenDriverNumber,
    this.position,
  });

  final DateTime date;
  final int meetingKey;
  final int sessionKey;
  final int overtakingDriverNumber;
  final int overtakenDriverNumber;
  final int? position;

  factory Overtake.fromJson(Map<String, dynamic> json) => Overtake(
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        meetingKey: asInt(json['meeting_key']) ?? 0,
        sessionKey: asInt(json['session_key']) ?? 0,
        overtakingDriverNumber: asInt(json['overtaking_driver_number']) ?? 0,
        overtakenDriverNumber: asInt(json['overtaken_driver_number']) ?? 0,
        position: asInt(json['position']),
      );
}

class RaceControlEvent {
  const RaceControlEvent({
    required this.date,
    this.driverNumber,
    this.flag,
    this.lapNumber,
    required this.meetingKey,
    this.message,
    this.scope,
    this.sector,
    required this.sessionKey,
    this.category,
  });

  final DateTime date;
  final int? driverNumber;
  final String? flag;
  final int? lapNumber;
  final int meetingKey;
  final String? message;
  final String? scope;
  final int? sector;
  final int sessionKey;
  final String? category;

  factory RaceControlEvent.fromJson(Map<String, dynamic> json) =>
      RaceControlEvent(
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        driverNumber: asInt(json['driver_number']),
        flag: asString(json['flag']),
        lapNumber: asInt(json['lap_number']),
        meetingKey: asInt(json['meeting_key']) ?? 0,
        message: asString(json['message']),
        scope: asString(json['scope']),
        sector: asInt(json['sector']),
        sessionKey: asInt(json['session_key']) ?? 0,
        category: asString(json['category']),
      );
}

class TeamRadio {
  const TeamRadio({
    required this.date,
    required this.driverNumber,
    required this.meetingKey,
    this.recordingUrl,
    required this.sessionKey,
  });

  final DateTime date;
  final int driverNumber;
  final int meetingKey;
  final String? recordingUrl;
  final int sessionKey;

  factory TeamRadio.fromJson(Map<String, dynamic> json) => TeamRadio(
        date: asDate(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
        driverNumber: asInt(json['driver_number']) ?? 0,
        meetingKey: asInt(json['meeting_key']) ?? 0,
        recordingUrl: asString(json['recording_url']),
        sessionKey: asInt(json['session_key']) ?? 0,
      );
}
