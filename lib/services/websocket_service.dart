import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vlrs/constants/websocket_constants.dart';
import 'package:vlrs/services/jwt_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  String? _jwtToken; // JWT Token
  late Stream<DateTime> _dateTimeStream; // Stream to listen to datetime
  final JwtService _jwtService = JwtService();

  final _hiveBox =
      Hive.box('vlrs'); // Hive.box: Stores JQT Token and Experied Tokens

  ///
  /// Gets the telemetry data published by devices from thingsboard.
  /// Return: WebSocketChannel, used to listen for incoming telemetry data.
  ///
  WebSocketChannel telemetryStream() {
    // URI for WebSocket connection
    final uri = Uri.parse('${WebSocketConstants.WS_URI}$_jwtToken');
    final telemetryStream =
        WebSocketChannel.connect(uri); // Connect to the WebSocket server.

    // JSON object containing subscription commands for telemetry data.
    var object = {
      'tsSubCmds': [
        {
          'entityType': 'DEVICE',
          'entityId': WebSocketConstants.PUBLISHER_DEVICE_ID_A,
          'scope': 'LATEST_TELEMETRY',
          'cmdId': 10
        },
        {
          'entityType': 'DEVICE',
          'entityId': WebSocketConstants.PUBLISHER_DEVICE_ID_B,
          'scope': 'LATEST_TELEMETRY',
          'cmdId': 11
        },
      ],
      'historyCmds': [],
      'attrSubCmds': []
    };

    // Convert the JSON object to a JSON-encoded string.
    final data = jsonEncode(object);

    // Send the JSON-encoded data to the ThingsBoard server via the WebSocket.
    telemetryStream.sink.add(data);

    return telemetryStream; // Returns the WebSocketChannel.
  }

  ///
  /// Validates the JWT token and ensures it is always up to date.
  ///
  /// * If the [_jwtToken] is null, send a new JQT token request.
  ///   * If the token is recieved successfully, store the new JWT
  ///     token and its expiration time in Hive.
  /// * Otherwise, check if the JWT token is expired.
  ///   * If expired, get a new JWT token.
  ///   * If not expired, periodically check if it has expired every minute.
  ///
  void validateToken() async {
    // Get the JWT token from the Hive storage (_hiveBox).
    _jwtToken = _hiveBox.get('token');

    // If the JWT token is null, send a request to get a new JWT token.
    if (_jwtToken == null) {
      assignNewJwtToken();
    } else {
      // If the JWT token is not null, check if it has expired.
      final tokenExpiryTime = _hiveBox.get('expiredToken');
      final tokenExpiryDateTime = DateTime.parse(tokenExpiryTime);
      final now = DateTime.now();

      // If the token has expired, send a request to get a new JWT token.
      if (now.isAfter(tokenExpiryDateTime)) {
        getNewJwtToken();
      } else {
        // If the token is not expired, periodically check if it has expired every minute.
        _dateTimeStream = Stream<DateTime>.periodic(
          const Duration(minutes: 1),
          (count) => DateTime.now(),
        );

        // Listen for events from the periodic stream.
        _dateTimeStream.listen((event) {
          // If the token has expired during the periodic check, send a request to get a new JWT token.
          if (event.isAfter(tokenExpiryDateTime)) {
            getNewJwtToken();
            _dateTimeStream.drain(); // Close stream
          }
        });
      }
    }
  }

  ///
  /// Retrieves and assignes a new JWT token.
  ///
  /// * If the token is recieved succefully, it is stored in the [_hiveBox]
  ///   and a new token expiry time is defined.
  ///
  void assignNewJwtToken() async {
    _jwtToken = await _jwtService.fetchJwtToken(); // Get new JWT Token.

    if (_jwtToken != null) {
      // If the request is successful, store the new JWT token and its expiration time in Hive.
      _hiveBox.put('token', _jwtToken);

      final tokenExpiryTime =
          DateTime.now().add(const Duration(minutes: 90)).toIso8601String();
      _hiveBox.put('expiredToken', tokenExpiryTime);
    }
  }

  ///
  /// Gets a new JWT token and stores it in the [_hiveBox].
  ///
  void getNewJwtToken() async {
    _jwtToken = await _jwtService.fetchJwtToken();
    _hiveBox.put('token', _jwtToken);
    validateToken();
  }

  void disposeWebSocketConnection() {
    _dateTimeStream.drain();
  }
}
