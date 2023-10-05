import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/model/telemetry.dart';
import 'package:vlrs/services/geolocation_service.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:vlrs/services/mqtt_client_service.dart';
import 'package:vlrs/services/mqtt_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GeolocationService _geolocationService = GeolocationService();
  late LatLng _userLatLng;

  bool _isLocationDataLoading = true;
  bool _isMqttClientConnected = false;

  final String _hostname = '43.226.218.94';
  final String _clientId = 'bfa1ffb0-585a-11ee-8816-b3b2ecd2ae97';
  final int _port = 1883;
  final String _accessToken = 'cngz9qqls7dk5zgi3y4j'; // bus a
  late MQTTClientService _mqttClientService;
  late MqttService mqttService;
  final String _pubTopic = 'v1/devices/me/telemetry';
  final _telemetryStream = WebSocketChannel.connect(Uri.parse(
      "ws://43.226.218.94:8080/api/ws/plugins/telemetry?token=eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZW5hbnRAdGhpbmdzYm9hcmQub3JnIiwidXNlcklkIjoiNDEwYTJkYjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwic2NvcGVzIjpbIlRFTkFOVF9BRE1JTiJdLCJzZXNzaW9uSWQiOiIwYmNmZDFkMC0wNGVlLTRiZjItOTVjYi1jZGYxZjRiNTAyYWIiLCJpc3MiOiJ0aGluZ3Nib2FyZC5pbyIsImlhdCI6MTY5NjUxOTAzOCwiZXhwIjoxNjk2NTI4MDM4LCJlbmFibGVkIjp0cnVlLCJpc1B1YmxpYyI6ZmFsc2UsInRlbmFudElkIjoiM2ZmYzQwMjAtNDE5Ni0xMWVlLTk2OWQtNWIyNDI0YTlhM2FkIiwiY3VzdG9tZXJJZCI6IjEzODE0MDAwLTFkZDItMTFiMi04MDgwLTgwODA4MDgwODA4MCJ9.QtqI9gMyqASoL9rGbnTPy1QhhpxqcON7dAikWvHpKoj8lOGf6IEM31QAi1hJhYBY2e492IDgde1E90ADBTItzg"));

  void _gettelemetryStream() {
    var object = {
      "tsSubCmds": [
        {
          "entityType": "DEVICE",
          "entityId": busAId,
          "scope": "LATEST_TELEMETRY",
          "cmdId": 10
        }
      ],
      "historyCmds": [],
      "attrSubCmds": []
    };
    var data = jsonEncode(object);
    _telemetryStream.sink.add(data);
  }

  @override
  void initState() {
    super.initState();
    _gettelemetryStream();
    _getUserLocation(); // Call the method to fetch the user's location
    _mqttClientService =
        MQTTClientService(_hostname, _clientId, _accessToken, _port);
    mqttService = MqttService(_hostname, _clientId, _accessToken, _port);
    _mqttClientService.establishConnection();
    // _establishClientConnection();
  }

  @override
  void dispose() {
    _mqttClientService.terminateClientConnection();
    super.dispose();
  }

  // Method to fetch and set the user's location
  Future<void> _getUserLocation() async {
    final userLocation = await _geolocationService.getCurrentUserLocation();
    setState(() {
      _userLatLng = userLocation; // Set user's location
      _isLocationDataLoading = false; // Set the data loading to false
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              _telemetryStream.sink.add(jsonEncode({
                "tsSubCmds": [
                  {
                    "entityType": "DEVICE",
                    "entityId": busAId,
                    "scope": "LATEST_TELEMETRY",
                    "cmdId": 10
                  }
                ],
                "historyCmds": [],
                "attrSubCmds": []
              }));
            },
          )
        ],
      ),
      body: _isLocationDataLoading == true ?
      // Show a loading indicator while waiting for user location
      Center(
        child: lottie.Lottie.asset("assets/animations/animation_lmpkib5u.json"),
      ): StreamBuilder(
        stream: _telemetryStream.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData == false) {
            _gettelemetryStream();
            return Center(
              child: Text("No Data"),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text("Error"),
            );
          }
          var json = jsonDecode(snapshot.data);
          var data = json['data'];
          var stringLat = data["latitude"][0][1];
          var stringLng = data["longitude"][0][1];
          var lat = double.parse(stringLat);
          var lng = double.parse(stringLng);
          print("Latitude" + stringLat);
          print("Longitude" + stringLng);
          return FlutterMap(
            options: MapOptions(
              center: LatLng(lat, lng), // Use the current location as the center
              zoom: 18,
              maxZoom: 18,
              minZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng), // Sets the marker on the user's current location
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.my_location,
                      size: 35.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLatLng,
                    radius: 8,
                    useRadiusInMeter: true,
                    color: const Color.fromRGBO(255, 255, 255, 1),
                  ),
                ],
              ),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _userLatLng,
                    radius: 6,
                    useRadiusInMeter: true,
                    color: const Color.fromRGBO(33, 150, 243, 1),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
