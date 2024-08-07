import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class MapRouteUI {
  // final MapRouteController _mapRouteController = MapRouteController();

  ///
  /// This function returns a PolylineLyaer that uses the list of
  /// latitudes and longitues provided from the param.
  ///
  /// Param: [latLngList], list of latitudes and longitues
  /// Param: [color], color of the route
  ///
  /// Returns: Widget, PolylineLayer
  Widget drawVehicleRoute(List<LatLng> latLngList, Color color) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: latLngList,
          color: color,
          strokeWidth: 4,
        ),
      ],
    );
  }
}
