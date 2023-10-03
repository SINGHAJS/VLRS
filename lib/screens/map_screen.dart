import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/services/geolocation_service.dart';
import 'package:lottie/lottie.dart' as lottie;

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
    _userLatLng = await _geolocationService.getCurrentUserLocation();
    setState(() {
      _isLocationDataLoading = false; // Set the data loading to false
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationDataLoading == true) {
      // Show a loading animation while waiting for user location
      return Center(
        child: lottie.Lottie.asset("assets/animations/animation_lmpkib5u.json"),
      );
    } else {
      return FlutterMap(
        options: MapOptions(
          center: _userLatLng, // Use the current location as the center
          zoom: 18, // Default zoom level
          maxZoom: 18, // Maximum zoom level
          minZoom: 14, // Minimum zoom level
        ),
        children: [
          // Sets the map layout
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
            // Set the inner circle for the marker of the user's location
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
    }
  }
}
