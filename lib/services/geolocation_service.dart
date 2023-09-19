import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:logger/logger.dart';

class GeolocationService {
  Position? _currentPosition;
  bool _isServicePermissionEnabled = false;
  final LatLng _defaultLatLng = const LatLng(36.8000, 175.1010);
  late LocationPermission _locationPermission;
  var logger = Logger();

  /// Retrieves the current user's location.
  ///
  /// This function checks if location services are enabled and if the app has
  /// permission to access the device's location. If location services are
  /// disabled or permission is denied, it logs appropriate messages and
  /// requests permission. If the current location is available, it returns
  /// a [LatLng] object representing the latitude and longitude of the user's
  /// location.
  ///
  /// If the current location cannot be obtained, it returns a default [LatLng]
  /// object with coordinates (36.8000, 175.1010).
  ///
  /// Returns a [Future] that completes with the [LatLng] object.
  Future<LatLng> getCurrentUserLocation() async {
    _isServicePermissionEnabled = await Geolocator.isLocationServiceEnabled();

    // Checks if the location service is disabled
    if (!_isServicePermissionEnabled) {
      logger.d("Location Service is Disabled");
    }

    // Checks the user permissions
    _locationPermission = await Geolocator.checkPermission();

    // Checks if the user has denied the location permission
    if (_locationPermission == LocationPermission.denied) {
      // Requests the user for location permission
      _locationPermission = await Geolocator.requestPermission();
    }

    // Sets the _currentPosition with the current location of the user
    _currentPosition = await Geolocator.getCurrentPosition();

    // If the _currentPosition is null, it is handled by returning a default LatLng object
    if (_currentPosition == null) {
      return _defaultLatLng;
    }

    // Returns the LatLng object with the current position of the user
    return LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
  }
}
