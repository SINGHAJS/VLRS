import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/controllers/bus_stop_controller.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/controllers/estimate_time_arrival_controller.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class BusStopUI {
  final BusStopController _busStopController = BusStopController();

  ///
  /// This function is responsible for returning the marker layer of bus stops.
  ///
  /// Param: [busStopList], list of bus stops
  /// Param: [publisherTelemetry], list of publisher devices
  ///
  /// Returns: Widget, MarkerLayer
  MarkerLayer displayBusStopOnMap(
      List<BusStop> busStopList,
      List<PublisherTelemetry> publisherTelemetry,
      List<BusStop> busStopsList,
      List<BusStop> forwardBusStopsList,
      List<BusStop> backwardBusStopsList,
      List<ETA> ETAsList) {
    List<Marker> busStopListClean = [];

    for (BusStop bStop in busStopList) {
      busStopListClean.add(
        Marker(
          width: 40,
          height: 40,
          point: LatLng(bStop.latitude, bStop.longitude),
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () => _busStopController.onBusStopMarkerHandler(
                  context, bStop, publisherTelemetry, busStopList),
              child: busStopIcon(bStop.name),
            );
          },
        ),
      );
    }

    return MarkerLayer(
      markers: busStopListClean,
    );
  }

  ///
  /// This function is responsible for returning the bus stop icon.
  ///
  /// Param: [title], name of icon
  ///
  /// Returns: Widget, Container
  Widget busStopIcon(String title) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.black, borderRadius: BorderRadius.circular(10.0)),
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
