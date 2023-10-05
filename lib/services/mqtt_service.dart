import 'package:logger/logger.dart';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:vlrs/constants/mqtt_constants.dart';

class MqttService {
  late MqttServerClient _client;
  var logger = Logger();

  MqttService(String hostname, String clientId, String accessToken, int port) {
    _client = MqttServerClient.withPort(hostname, clientId, port);

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

  /// Establishes a connection with the mqtt broker
  ///
  /// This function uses the [MqttConstants.ACCESS_TOKEN] and the [MqttConstants.CLIENT_ID]
  /// to establish and authenticate the connection with the mqtt broker.
  ///
  /// If the client is connected to the mqtt broker succesfully, it will return true, otherwise
  /// it will return false.
  ///
  /// Returns a boolean value indicating the connection state.
  Future<bool> establishConnection() async {
    final connectMessage = MqttConnectMessage()
        .authenticateAs(MqttConstants.ACCESS_TOKEN, '')
        .withClientIdentifier(MqttConstants.CLIENT_ID)
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

  /// This function disconnects the client from the mqtt broker.
  void terminateClientConnection() {
    _client.disconnect();
  }

  /// Logs a message when the client is conncted.
  void _onConnected() {
    logger.i('MQTT_LOGS:: Connected');
  }

  /// Logs a message when the client is disconnected.
  void _onDisconnected() {
    logger.i('MQTT_LOGS:: Disconnected');
  }

  /// Logs a message when the client subscribes to a topic.
  void _onSubscribed(String topic) {
    logger.i('MQTT_LOGS:: Subscribed topic: $topic');
  }

  /// Logs a message when the client unsubscribes from a topic.
  void _onSubscribeFail(String topic) {
    logger.i('MQTT_LOGS:: Failed to subscribe $topic');
  }

  /// Logs a message when the client unsubscribes from a topic.
  void _onUnsubscribed(String? topic) {
    logger.i('MQTT_LOGS:: Unsubscribed topic: $topic');
  }

  /// Logs a message when the client recieves a ping.
  void _pong() {
    logger.i('MQTT_LOGS:: Ping response client callback invoked');
  }

  void publishMessage(String topic, MqttQos qos, String message) {
    final payloadBuilder = MqttClientPayloadBuilder();
    // final b = Unit8Buffer();

    try {
      payloadBuilder.addString(message);
      _client.publishMessage(topic, qos, payloadBuilder.payload!);
      logger.i('MQTT_LOGS:: Publish message $message to topic $topic');
    } catch (e) {
      logger.e('Exception: $e');
      terminateClientConnection();
    }
  }
}
