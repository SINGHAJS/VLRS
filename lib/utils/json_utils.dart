import 'package:latlong2/latlong.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:async' show Future;

class JsonUtils {
  Future<List<LatLng>> readLatLngFromJson() async {
    final String jsonString =
        await rootBundle.loadString('assets/coordinates/RouteCoords.json');

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
