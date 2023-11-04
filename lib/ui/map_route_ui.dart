import 'package:vlrs/ui/error_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapRouteUI {
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
