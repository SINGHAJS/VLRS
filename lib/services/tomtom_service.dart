import 'package:latlong2/latlong.dart';
import 'package:vlrs/constants/tomtom_constants.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TomTomService {
  final Logger _logger = Logger();

  TomTomService();

  ///
  /// This function is responsible retrieving the route data using the tomtom
  /// api.
  ///
  /// Param: [origin], the latlng of the origin
  /// Param: [destination], the latlng of the  destination
  ///
  /// Return Future<Map<String, dynamic>>, summary.
  ///
  Future<Map<String, dynamic>> retrieveRouteDataUsingHttp(
      LatLng origin, LatLng destination) async {
    final response = await http.get(Uri.parse(
        'https://api.tomtom.com/routing/1/calculateRoute/${origin.latitude},${origin.longitude}:${destination.latitude},${destination.longitude}/json?key=${TomTomConstants.API_KEY}'));

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = responseData['routes'] as List<dynamic>;
      final firstRoute = routes.first as Map<String, dynamic>;
      final summary = firstRoute['summary'] as Map<String, dynamic>;

      print(summary);

      return summary;
    } else {
      _logger.e('Failed to load route api data.');
      throw Exception('Failed to load route api data.');
    }
  }
}
