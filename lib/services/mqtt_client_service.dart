import 'package:logger/logger.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTClientService {
  late MqttServerClient _client;
  late String _clientId;
  late String _accessToken;
  var logger = Logger();

  MQTTClientService(
      String hostname, String clientId, String accessToken, int port) {
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
    return _client.connectionStatus!.state == MqttConnectionState.connected;
    // if (_client.connectionStatus!.state == MqttConnectionState.connected) {
    //   logger.i('MQTT_LOGS::Mosquitto client connected');
    // } else {
    //   logger.i(
    //       'MQTT_LOGS::ERROR Mosquitto client connection failed - disconnecting, status is ${_client.connectionStatus}');
    //   _client.disconnect();
    // }
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
}
