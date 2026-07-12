import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final mqttClientProvider = Provider<MqttService>((ref) {
  return MqttService();
});

class MqttService {
  MqttServerClient? _client;
  final Map<String, Function(String)> _subscriptions = {};

  MqttServerClient get client {
    _client ??= MqttServerClient.withPort(
      AppConstants.mqttBroker,
      'hunter360_client_${DateTime.now().millisecondsSinceEpoch}',
      AppConstants.mqttPort,
    );
    return _client!;
  }

  Future<bool> connect() async {
    try {
      client.logging(on: false);
      client.keepAlivePeriod = 60;
      client.autoReconnect = true;
      client.resubscribeOnAutoReconnect = true;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier('hunter360')
          .startClean()
          .withWillQos(MqttQos.atLeastOnce);

      client.connectionMessage = connMessage;

      await client.connect();
      return client.connectionStatus?.state == MqttConnectionState.connected;
    } catch (e) {
      client.disconnect();
      return false;
    }
  }

  void subscribe(String topic, Function(String) callback) {
    _subscriptions[topic] = callback;
    client.subscribe(topic, MqttQos.atLeastOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (final message in messages) {
        if (_subscriptions.containsKey(message.topic)) {
          final payload = MqttPublishPayload.bytesToStringAsString(
            (message.payload as MqttPublishMessage).payload.message,
          );
          _subscriptions[message.topic]!(payload);
        }
      }
    });
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void unsubscribe(String topic) {
    _subscriptions.remove(topic);
    client.unsubscribe(topic);
  }

  void disconnect() {
    client.disconnect();
  }
}
