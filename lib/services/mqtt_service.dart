import 'package:logger/logger.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient _client;
  late String _clientId;
  late String _accessToken;
  var logger = Logger();

  MqttService(String hostname, String clientId, String accessToken, int port) {
    _client = MqttServerClient.withPort(hostname, clientId, port);

    _clientId = clientId;
    _accessToken = accessToken;

    _client.logging(on: true);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pong;
    _client.keepAlivePeriod = 60;
    _client.setProtocolV311();
  }

  Future<bool> establishConnection() async {
    final connectMessage = MqttConnectMessage()
        .authenticateAs(_accessToken, '')
        .withClientIdentifier(_clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    logger.i('MQTT_LOGS::Mosquitto client connecting....');

    _client.connectionMessage = connectMessage;

    try {
      await _client.connect();
    } catch (e) {
      logger.e('Exception: $e');
      _client.disconnect();
    }

    if (_client.connectionStatus!.state == MqttConnectionState.connected) {
      logger.i('MQTT_LOGS::Mosquitto client connected');
      return true;
    } else {
      logger.i(
          'MQTT_LOGS::ERROR Mosquitto client connection failed - disconnecting, status is ${_client.connectionStatus}');
      terminateClientConnection();
      return false;
    }
  }

  void terminateClientConnection() {
    _client.disconnect();
  }

  void _onConnected() {
    logger.i('MQTT_LOGS:: Connected');
  }

  void _onDisconnected() {
    logger.i('MQTT_LOGS:: Disconnected');
  }

  void _onSubscribed(String topic) {
    logger.i('MQTT_LOGS:: Subscribed topic: $topic');
  }

  void _onSubscribeFail(String topic) {
    logger.i('MQTT_LOGS:: Failed to subscribe $topic');
  }

  void _onUnsubscribed(String? topic) {
    logger.i('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  void _pong() {
    logger.i('MQTT_LOGS:: Ping response client callback invoked');
  }

  void publishMessage(String topic, String data) {
    final builder = MqttClientPayloadBuilder();

    try {
      builder.addString(data);
      _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    } catch (e) {
      logger.e('Exception: $e');
      terminateClientConnection();
    }
  }

  void subscribeToTopic(String topic) {
    try {
      logger.i('MQTT_LOGS:: Subscribing to the $topic topic');

      _client.subscribe(topic, MqttQos.atLeastOnce);
      _client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage recMess = c[1].payload as MqttPublishMessage;
        String payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        logger.i(
            "MQTTClient:: Message received from topic ${c[1].topic}, message = $payload");
      });
    } catch (e) {
      logger.e('Exception: $e');
      terminateClientConnection();
    }
  }

  void onMessageReceived(String topic, String message) {
    // Handle the received message here
    logger.i('Received message on topic $topic: $message');
    // You can process or store the message data as needed
  }
}
