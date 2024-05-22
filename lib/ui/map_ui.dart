import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/constants/constants.dart';
import 'package:vlrs/ui/error_ui.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:logger/logger.dart';

class MapUI {
  late final ErrorUI _errorUI = ErrorUI();
  final String busImagePath = 'assets/images/map_screen/bus.png';
  final MapRouteController _mapRouteController = MapRouteController();
  final Logger logger = Logger();

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
  // Marker showUserMarkerOnMapUI(LatLng userLatLng) {
  //   return Marker(
  //     point: userLatLng,
  //     width: 80,
  //     height: 80,
  //     builder: (context) => const Icon(
  //       Icons.my_location,
  //       size: 35.0,
  //       color: Colors.red,
  //     ),
  //   );
  // }

  ///
  /// This function returns circular layer for the user's current location.
  /// Param: [userLatLng], lat and long of user's location
  ///
  /// Return: Widget, CircularLayer.
  ///
  Widget showUserCircleLayerOnMapUI(LatLng userLatLng) {
    double innerRadius = 18;
    double outerRadius = 14;

    return CircleLayer(
      circles: [
        CircleMarker(
          point: userLatLng,
          radius: innerRadius,
          useRadiusInMeter: true,
          color: const Color.fromRGBO(255, 255, 255, 1),
        ),
        CircleMarker(
          point: userLatLng,
          radius: outerRadius,
          useRadiusInMeter: true,
          color: const Color.fromRGBO(33, 150, 243, 1),
        ),
      ],
    );
  }

  ///
  /// This function returns a marker for the publisher device's current location
  /// given in the list.
  /// Param: [telemetryDevices], the list of telemetry devices
  ///
  /// Return: Widget, Marker.
  ///
  MarkerLayer showMultiplePublisherDeviceMarkerOnMap(
    List<PublisherTelemetry> telemetryDevices,
  ) {
    List<Marker> markerListClean = [];

    if (telemetryDevices.isNotEmpty) {
      for (PublisherTelemetry telemetryDevice in telemetryDevices) {
        double busDirection = (telemetryDevice.bearing) * (3.1415926535 / 180);

        markerListClean.add(
          Marker(
            point: LatLng(telemetryDevice.latitude, telemetryDevice.longitude),
            width: 80,
            height: 80,
            builder: (BuildContext context) {
              return GestureDetector(
                onTap: () => logger.i('BUS BUTTON CLICKED'),
                child: Transform.rotate(
                  angle: busDirection,
                  child: Image.asset(busImagePath),
                ),
              );
            },
          ),
        );
      }
    }

    return MarkerLayer(
      markers: markerListClean,
    );
  }
}
