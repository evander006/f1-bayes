import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';

MqttClient createPlatformMqttClient({
  required String clientId,
  required bool webSocket,
}) {
  final client = MqttBrowserClient('wss://mqtt.openf1.org:8084/mqtt', clientId);
  client.port = 8084;
  client.websocketProtocols = ['mqtt'];
  return client;
}
