import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/services/geolocation_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final GeolocationService _geolocationService = GeolocationService();
  bool _isLocationDataLoading = true;
  late LatLng _userLatLng;

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Call the method to fetch the user's location
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
    if (_isLocationDataLoading == true) {
      // Show a loading indicator while waiting for user location
      return const Center(
        child: CircularProgressIndicator(),
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
          )
        ],
      );
    }
  }
}
