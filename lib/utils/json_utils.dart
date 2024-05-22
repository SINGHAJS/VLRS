import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async' show Future;

import 'package:vlrs/model/bus_stop.dart';

class JsonUtils {
  ///
  /// This function takes a filename that contains the coordinates
  /// data and adds the coordinates as Lat and Lng objects into a list.
  ///
  /// Param: [fileName], path to the file
  ///
  /// Return: List<LatLng>, list of LatLng objects
  ///
  Future<List<LatLng>> readLatLngFromJson(String fileName) async {
    final String jsonString = await rootBundle.loadString(fileName);

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<LatLng> latLngs = [];

    jsonData.forEach((key, value) {
      final List<dynamic> coordinates = value as List<dynamic>;
      for (final dynamic coordData in coordinates) {
        final LatLng latLng =
            LatLng(coordData['latitude'], coordData['longitude']);
        latLngs.add(latLng);
      }
    });
    return latLngs;
  }

  ///
  /// This function takes a filename that contains the bus stop
  /// data and adds the name and coordinates as Lat and Lng objects into a list.
  ///
  /// Param: [fileName], path to the file
  ///
  /// Return: List<BusStop>, list of BusStop objects
  ///
  Future<List<BusStop>> readBusStopDataFromJson(String fileName) async {
    final String jsonString = await rootBundle.loadString(fileName);
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List<BusStop> busStops = [];

    jsonData.forEach((key, value) {
      final List<dynamic> coordinates = value as List<dynamic>;
      for (final dynamic data in coordinates) {
        final BusStop busStop = BusStop(
            name: data['bus-stop-name'] as String,
            latitude: data['latitude'] as double,
            longitude: data['longitude'] as double,
            distanceToNextStop: data['distance-to-next-stop'] as num);
        busStops.add(busStop);
      }
    });

    return busStops;
  }
}
