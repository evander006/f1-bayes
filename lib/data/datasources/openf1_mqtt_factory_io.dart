import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient createPlatformMqttClient({
  required String clientId,
  required bool webSocket,
}) {
  if (webSocket) {
    final client = MqttServerClient.withPort('mqtt.openf1.org', clientId, 8084);
    client.useWebSocket = true;
    client.secure = true;
    client.websocketProtocols = ['mqtt'];
    return client;
  }
  final client = MqttServerClient.withPort('mqtt.openf1.org', clientId, 8883);
  client.secure = true;
  client.useWebSocket = false;
  return client;
}
