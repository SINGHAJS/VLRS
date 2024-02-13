import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class MapRouteUI {
  final String _busStopImagePath = 'assets/images/map_screen/bus-stop.png';
  final MapRouteController _mapRouteController = MapRouteController();

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

  ///
  /// This function returns  multiple markers of a the stops from the list given.
  /// Param: [markerList], list of marker data
  /// Param: [publisherTelemetry], publisher telemetry object
  ///
  /// Return: Widget, MarkerLayer
  ///
  MarkerLayer displayBusStopOnMap(
      List<BusStop> markerList, PublisherTelemetry publisherTelemetry) {
    List<Marker> markerListClean = [];

    for (BusStop bStop in markerList) {
      markerListClean.add(Marker(
        width: 80,
        height: 80,
        point: LatLng(bStop.latitude, bStop.longitude),
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => _mapRouteController.onBusStopMarkerHandler(
                context, bStop, publisherTelemetry),
            child: Image.asset(_busStopImagePath),
          );
        },
      ));
    }

    return MarkerLayer(
      markers: markerListClean,
    );
  }

  MarkerLayer displayBusStopOnMapAdvanced(
      List<BusStop> markerList, List<PublisherTelemetry> publisherTelemetry) {
    List<Marker> markerListClean = [];

    for (BusStop bStop in markerList) {
      markerListClean.add(Marker(
        width: 80,
        height: 80,
        point: LatLng(bStop.latitude, bStop.longitude),
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => _mapRouteController.onBusStopMarkerHandlerAdvanced(
                context, bStop, publisherTelemetry),
            child: Image.asset(_busStopImagePath),
          );
        },
      ));
    }

    return MarkerLayer(
      markers: markerListClean,
    );
  }
}
