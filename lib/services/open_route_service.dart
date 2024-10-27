import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:vlrs/model/open_route_service_info.dart';

class OpenRouteService {
  static const String _apiKey =
      '5b3ce3597851110001cf624804ab2baa18644cc6b65c5829826b6117';
  static const String _url =
      'https://api.openrouteservice.org/v2/directions/driving-car';

  // static const String _url =
  //     'http://43.226.218.99:8080/ors/v2/directions/driving-car';

  /// Estimates the travel time from one point to another using the OpenRouteService (ORS) API.
  ///
  /// @param coordinates The cordinates it must hit.
  ///
  /// @return The estimated travel time in the format HH:MM:SS.
  ///
  /// @throws IOException if the network request fails or if no routes are found.
  static Future<String> getEstimateTimeFromPointToPoint(
      List<List<double>> coordinates) async {
    final Logger _logger = Logger();
    _logger.d(coordinates);

    // Construct JSON body
    final body = jsonEncode({'coordinates': coordinates});

    // Set headers
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: body,
    );

    // Handle response
    if (response.statusCode != 200) {
      throw HttpException('Unexpected status code ${response.statusCode}');
    }

    // Parse response and calculate ETA
    final jsonResponse = jsonDecode(response.body);
    final routes = jsonResponse['routes'];
    if (routes.isNotEmpty) {
      final route = routes[0];
      final durationSeconds = route['summary']['duration']; // in seconds

      final hours = durationSeconds ~/ 3600;
      final minutes = (durationSeconds % 3600) ~/ 60;
      final seconds = durationSeconds % 60;

      // Format seconds to two decimal places and remove trailing zeros
      final formattedSeconds = seconds
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');

      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${formattedSeconds.padLeft(2, '0')}';
    } else {
      return "OpenRouteService: No Route Found";
    }
  }

  static Future<double> getTotalDistanceFromPointToPoint(
      List<List<double>> coordinates) async {
    final Logger logger = Logger();
    logger.d(coordinates);

    // Construct JSON body
    final body = jsonEncode({'coordinates': coordinates});

    // Set headers
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: body,
    );

    // Handle response
    if (response.statusCode != 200) {
      throw HttpException('Unexpected status code ${response.statusCode}');
    }

    // Parse response and calculate ETA
    final jsonResponse = jsonDecode(response.body);
    final routes = jsonResponse['routes'];
    if (routes.isNotEmpty) {
      final route = routes[0];
      final distanceInMeters = route['summary']['distance']; // in meters

      return distanceInMeters;
    }

    return -1;
  }

  static Future<OpenRouteServiceInfo> getORSInfoObject(
      List<List<double>> coordinates) async {
    final Logger logger = Logger();
    logger.d(coordinates);

    // Construct JSON body
    final body = jsonEncode({'coordinates': coordinates});

    // Set headers
    final headers = {
      HttpHeaders.authorizationHeader: 'Bearer $_apiKey',
      HttpHeaders.contentTypeHeader: 'application/json; charset=utf-8',
    };

    // Make the HTTP POST request
    final response = await http.post(
      Uri.parse(_url),
      headers: headers,
      body: body,
    );

    // Handle response
    if (response.statusCode != 200) {
      throw HttpException('Unexpected status code ${response.statusCode}');
    }

    // Parse response and calculate ETA
    final jsonResponse = jsonDecode(response.body);
    final routes = jsonResponse['routes'];
    if (routes.isNotEmpty) {
      final route = routes[0];
      final distanceInMeters = route['summary']['distance']; // in meters
      final distanceInKMs = distanceInMeters / 1000; // in kilometers
      final durationSeconds = route['summary']['duration']; // in seconds

      final hours = durationSeconds ~/ 3600;
      final minutes = (durationSeconds % 3600) ~/ 60;
      final seconds = durationSeconds % 60;

      // Format seconds to two decimal places and remove trailing zeros
      final formattedSeconds = seconds
          .toStringAsFixed(2)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
      final estimateTimeOfArrival =
          '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${formattedSeconds.padLeft(2, '0')}';

      return OpenRouteServiceInfo(
          estimateTimeOfArrival: estimateTimeOfArrival,
          distance: distanceInKMs);
    } else {
      return OpenRouteServiceInfo();
    }
  }
}
