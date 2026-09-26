import 'package:mqtt_client/mqtt_client.dart';

import 'openf1_mqtt_factory_stub.dart'
    if (dart.library.io) 'openf1_mqtt_factory_io.dart'
    if (dart.library.html) 'openf1_mqtt_factory_web.dart';

MqttClient createOpenF1MqttClient({
  required String clientId,
  required bool webSocket,
}) =>
    createPlatformMqttClient(clientId: clientId, webSocket: webSocket);
