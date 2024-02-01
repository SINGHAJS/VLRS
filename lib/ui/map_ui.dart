import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/constants/constants.dart';
import 'package:vlrs/ui/error_ui.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class MapUI {
  late final ErrorUI _errorUI = ErrorUI();
  final String busImagePath = 'assets/images/map_screen/bus.png';

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
  /// This function returns a marker for the user's current location.
  /// Param: [userLatLng], lat and long of user's location.
  ///
  /// Return: Widget, Marker.
  ///
  Marker showUserMarkerOnMapUI(LatLng userLatLng) {
    return Marker(
      point: userLatLng,
      width: 80,
      height: 80,
      builder: (context) => const Icon(
        Icons.my_location,
        size: 35.0,
        color: Colors.red,
      ),
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

  ///
  /// This function returns a marker for the publisher device's current location.
  /// Param: [publisherDeviceLatLng], lat and long of publisher device's location.
  /// Param: [bearing], bearing data of the publisher device to point the bus
  ///        to that direction.
  ///
  /// Return: Widget, Marker.
  ///
  Marker showPublisherDeviceMarkerOnMap(
      LatLng publisherDeviceLatLng, double bearing) {
    // double busDirection = (90 - bearing) * (3.1415926535 / 180);
    double busDirection = (90 - bearing) * (Constants.PI / 180);

    return Marker(
      point: publisherDeviceLatLng,
      width: 80,
      height: 80,
      builder: (context) => Transform.rotate(
        angle: busDirection,
        child: Image.asset(busImagePath),
      ),
    );
  }

  ///
  /// This function returns a marker for the publisher device's current location
  /// given in the list.
  /// Param: [telemetryDevices], the list of telemetry devices
  ///
  /// Return: Widget, Marker.
  ///
  // Marker showPublisherDeviceMarkerOnMap(
  //     List<PublisherTelemetry> telemetryDevices) {
  //   if (telemetryDevices.isNotEmpty) {
  //     for (PublisherTelemetry telemetryDevice in telemetryDevices) {
  //       double busDirection =
  //           (90 - telemetryDevice.bearing) * (3.1415926535 / 180);

  //       return Marker(
  //         point: LatLng(telemetryDevice.latitude, telemetryDevice.longitude),
  //         width: 80,
  //         height: 80,
  //         builder: (context) => Transform.rotate(
  //           angle: busDirection,
  //           child: Image.asset(busImagePath),
  //         ),
  //       );
  //     }
  //   }

  //   return Marker(
  //     point: const LatLng(-36.785334, 175.023230),
  //     width: 80,
  //     height: 80,
  //     builder: (context) => Image.asset(busImagePath),
  //   );
  // }
}
