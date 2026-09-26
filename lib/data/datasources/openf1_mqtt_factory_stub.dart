import 'package:mqtt_client/mqtt_client.dart';

MqttClient createPlatformMqttClient({
  required String clientId,
  required bool webSocket,
}) {
  throw UnsupportedError('MQTT is not available on this platform');
}
