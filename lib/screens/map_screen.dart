import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// Geolocation and map
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/services/geolocation_service.dart';

// Animation
import 'package:lottie/lottie.dart' as lottie;

// Web Socket
import 'package:web_socket_channel/web_socket_channel.dart';

import '../config/constants.dart';

// Mqtt
import 'package:vlrs/services/mqtt_service.dart';
import 'package:vlrs/constants/mqtt_constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Logger
  var _logger = Logger();

  // Geolocation
  final GeolocationService _geolocationService = GeolocationService();
  late LatLng _userLatLng;

  // Mqtt
  late MqttService _mqttClientService;
  late MapController _mapController;
  final box = Hive.box('vlrs');

  // Flags
  bool _isLocationDataLoading = true;
  bool _isMqttClientConnected = false;

  final _telemetryStream = WebSocketChannel.connect(Uri.parse(
      "ws://43.226.218.94:8080/api/ws/plugins/telemetry?token=$token"));

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

  void _checkJwtToken() {
    var jwtToken = box.get('jwtToken');
    final dio = Dio();
    if (jwtToken == null) {
      var result   =dio.post("http://43.226.218.94:8080/api/auth/login");
    }
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController(); // Initialise the map controller
    _gettelemetryStream();
    _getUserLocation(); // Call the method to fetch the user's location

    _mqttClientService = MqttService(
        MqttConstants.HOSTNAME,
        MqttConstants.CLIENT_ID,
        MqttConstants.ACCESS_TOKEN,
        MqttConstants.PORT); // Initialise the mqtt client service

    _setUpMqttCommunication(); // Call the setup method to set up the mqtt communication
  }

  // Method to fetch and set the user's location
  Future<void> _getUserLocation() async {
    _userLatLng = await _geolocationService.getCurrentUserLocation();
    setState(() {
      _isLocationDataLoading = false; // Set the data loading to false
    });
  }

  Future<void> _setUpMqttCommunication() async {
    _isMqttClientConnected = await _mqttClientService.establishConnection();

    if (_isMqttClientConnected) {
      setState(() {
        // Perform publish or subscription
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: StreamBuilder(
        stream: _telemetryStream.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData == false) {
            _gettelemetryStream();
            // Show a loading indicator while waiting for user and other devices location
            return Center(
              child: lottie.Lottie.asset(
                  "assets/animations/animation_lmpkib5u.json"),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }
          var json = jsonDecode(snapshot.data);
          var data = json['data'];
          var stringLat = data["latitude"][0][1];
          var stringLng = data["longitude"][0][1];
          var lat = double.parse(stringLat);
          var lng = double.parse(stringLng);
          moveMapCenter(lat, lng);
          _logger.d('Latitude $stringLat');
          _logger.d('Longitude $stringLng');
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center:
                  LatLng(lat, lng), // Use the current location as the center
              zoom: 18, // Default zoom level
              maxZoom: 18, // Maximum zoom level
              minZoom: 14, // Minimum zoom level
            ),
            children: [
              // Sets the map layout
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vlrs.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat,
                        lng), // Sets the marker on the user's current location
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
              MarkerLayer(
                markers: [
                  Marker(
                    point:
                        _userLatLng, // Sets the marker on the user's current location
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
                    // Set the outer circler for the marker of the user's location
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
                    // Set the inner circle for the marker of the user's location
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

  void moveMapCenter(double lat, double lng) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      _mapController.move(LatLng(lat, lng), 18);
    });
  }
}
