import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/services/geolocation_service.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:vlrs/services/mqtt_client_service.dart';

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

  final String _brokerURL = '43.226.218.94';
  final String _clientId = 'bfa1ffb0-585a-11ee-8816-b3b2ecd2ae97';
  final int _port = 1883;
  final String _accessToken = 'TRB8zmWVjcJYFssMtGCX';
  late MQTTClientService _mqttClientService;
  final String _pubTopic = 'v1/devices/me/telemetry';

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Call the method to fetch the user's location
    _mqttClientService =
        MQTTClientService(_brokerURL, _clientId, _accessToken, _port);
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

  Future<void> _establishClientConnection() async {
    await _mqttClientService.establishConnection();
    setState(() {
      _isMqttClientConnected = true;
    });

    if (_isMqttClientConnected) {
      // _mqttClientService.publishMessage(_pubTopic, "{flutter: ${303.00}}");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationDataLoading == true) {
      // Show a loading indicator while waiting for user location
      return Center(
        child: lottie.Lottie.asset("assets/animations/animation_lmpkib5u.json"),
      );
    } else {
      return FlutterMap(
        options: MapOptions(
          center: _userLatLng, // Use the current location as the center
          zoom: 18,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
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
        ],
      );
    }
  }
}
