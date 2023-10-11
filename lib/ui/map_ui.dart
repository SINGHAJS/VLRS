import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/ui/error_ui.dart';

class MapUI {
  late final ErrorUI _errorUI = ErrorUI();

  ///
  /// This function is used to validate if the map widget is ready.
  ///
  /// Return: Boolean, true if ready, false if not.
  ///
  bool isMapWidgetReady(AsyncSnapshot snapshot, bool isUserLocationAttained) {
    if (snapshot.connectionState == ConnectionState.waiting ||
        snapshot.hasData == false) return false;

    if (isUserLocationAttained == false) return false;

    if (snapshot.hasError) _errorUI.showErrorMessage();

    return true;
  }

  ///
  /// This function returns a marker layer for the user's current location.
  /// Param: [userLatLng], lat and long of user's location.
  ///
  /// Return: Widget, MarkerLayer.
  ///
  Widget showUserMarkerOnMapUI(LatLng userLatLng) {
    return MarkerLayer(
      markers: [
        Marker(
          point: userLatLng,
          width: 80,
          height: 80,
          builder: (context) => const Icon(
            Icons.my_location,
            size: 35.0,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  ///
  /// This function returns circular layer for the user's current location.
  /// Param: [userLatLng], lat and long of user's location
  ///
  /// Return: Widget, CircularLayer.
  ///
  Widget showUserCircleLayerOnMapUI(LatLng userLatLng) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: userLatLng,
          radius: 18,
          useRadiusInMeter: true,
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        CircleMarker(
          point: userLatLng,
          radius: 14,
          useRadiusInMeter: true,
          color: const Color.fromRGBO(33, 150, 243, 1),
        ),
      ],
    );
  }
}
