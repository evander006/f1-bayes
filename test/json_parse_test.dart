import 'package:f1_app/data/json_parse.dart';
import 'package:f1_app/data/models/openf1_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses nullable OpenF1 driver payload', () {
    final driver = Driver.fromJson({
      'broadcast_name': 'L NORRIS',
      'driver_number': 1,
      'first_name': 'Lando',
      'full_name': 'Lando NORRIS',
      'last_name': 'Norris',
      'meeting_key': 1295,
      'name_acronym': 'NOR',
      'session_key': 11373,
      'team_colour': 'F47600',
      'team_name': 'McLaren',
      'headshot_url': null,
      'country_code': null,
    });
    expect(driver.driverNumber, 1);
    expect(driver.shortName, 'L. Norris');
    expect(driver.teamColorValue, int.parse('FFF47600', radix: 16));
  });

  test('invalid team colour falls back', () {
    expect(parseTeamColorValue('zz'), 0xFFE10600);
    expect(parseTeamColorValue(null), 0xFFE10600);
  });
}
