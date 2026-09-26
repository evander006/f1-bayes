import 'package:f1_app/data/datasources/openf1_mqtt.dart';
import 'package:f1_app/data/models/openf1_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decodes MQTT object payload and ignores _id/_key', () {
    final rows = decodeMqttPayload(
      '{"meeting_key":1257,"session_key":10007,"driver_number":31,"date":"2025-04-11T11:21:16.603025+00:00","x":1,"y":2,"z":0,"_key":"k","_id":1}',
    );
    expect(rows, hasLength(1));
    final point = LocationPoint.fromJson(rows.single);
    expect(point.driverNumber, 31);
    expect(point.x, 1);
    expect(point.y, 2);
  });

  test('decodes MQTT list payload', () {
    final rows = decodeMqttPayload('[{"driver_number":1,"position":2},{"driver_number":4,"position":1}]');
    expect(rows, hasLength(2));
  });
}
