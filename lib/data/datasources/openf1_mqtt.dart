import 'dart:async';
import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';

import 'openf1_mqtt_factory.dart';

class OpenF1MqttMessage {
  const OpenF1MqttMessage({required this.topic, required this.payload});

  final String topic;
  final Map<String, dynamic> payload;
}

class OpenF1Mqtt {
  OpenF1Mqtt();

  static const topics = [
    'v1/position',
    'v1/intervals',
    'v1/laps',
    'v1/stints',
    'v1/location',
    'v1/weather',
  ];

  final _controller = StreamController<OpenF1MqttMessage>.broadcast();
  MqttClient? _client;
  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>? _updates;
  String? transport;

  Stream<OpenF1MqttMessage> get messages => _controller.stream;
  bool get isConnected =>
      _client?.connectionStatus?.state == MqttConnectionState.connected;

  Future<String> connect({
    required String username,
    required String token,
  }) async {
    await disconnect();
    final clientId = 'f1app-${DateTime.now().millisecondsSinceEpoch}';
    try {
      await _open(clientId: clientId, username: username, token: token, webSocket: false);
      transport = 'mqtt';
    } catch (_) {
      await _open(clientId: clientId, username: username, token: token, webSocket: true);
      transport = 'websocket';
    }
    return transport!;
  }

  Future<void> _open({
    required String clientId,
    required String username,
    required String token,
    required bool webSocket,
  }) async {
    final client = createOpenF1MqttClient(clientId: clientId, webSocket: webSocket);
    client.logging(on: false);
    client.keepAlivePeriod = 30;
    client.autoReconnect = true;
    client.resubscribeOnAutoReconnect = true;
    client.setProtocolV311();
    client.connectionMessage = MqttConnectMessage()
        .authenticateAs(username, token)
        .startClean()
        .withClientIdentifier(clientId)
        .withWillQos(MqttQos.atMostOnce);

    _client = client;
    final status = await client.connect(username, token);
    if (status?.state != MqttConnectionState.connected) {
      client.disconnect();
      throw StateError('OpenF1 MQTT connect failed: ${status?.state}');
    }

    for (final topic in topics) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }

    final updates = client.updates;
    if (updates == null) {
      throw StateError('OpenF1 MQTT has no update stream');
    }
    _updates = updates.listen(_onPackets);
  }

  void _onPackets(List<MqttReceivedMessage<MqttMessage>> packets) {
    for (final packet in packets) {
      final message = packet.payload;
      if (message is! MqttPublishMessage) continue;
      final raw = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      for (final payload in decodeMqttPayload(raw)) {
        if (!_controller.isClosed) {
          _controller.add(OpenF1MqttMessage(topic: packet.topic, payload: payload));
        }
      }
    }
  }

  Future<void> disconnect() async {
    await _updates?.cancel();
    _updates = null;
    _client?.disconnect();
    _client = null;
    transport = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}

List<Map<String, dynamic>> decodeMqttPayload(String raw) {
  if (raw.isEmpty) return const [];
  final data = jsonDecode(raw);
  if (data is Map) {
    return [Map<String, dynamic>.from(data)];
  }
  if (data is List) {
    return [
      for (final item in data)
        if (item is Map) Map<String, dynamic>.from(item),
    ];
  }
  return const [];
}
