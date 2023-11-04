import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async' show Future;

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
}
