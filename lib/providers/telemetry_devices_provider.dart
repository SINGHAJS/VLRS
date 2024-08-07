import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class TelemetryDevicesNotifier extends StateNotifier<List<PublisherTelemetry>> {
  TelemetryDevicesNotifier() : super([]);
  final Logger _logger = Logger();

  ///
  /// This function takes the data snapshot and creates/updates a
  /// [PublisherTelemetry] object.
  ///
  /// [dataSnapshot] - String value of the snapshot data
  ///
  void addPublisherTelemetryDevice(String? dataSnapshot) {
    if (dataSnapshot == null) {
      return; // Exit if the dataSnapshot is null
    }

    final json = jsonDecode(dataSnapshot);
    if (json == null || json['data'] == null) {
      return; // Exit if json or json['data'] is null
    }

    final data = json['data'];
    String aid = data["aid"]?[0]?[1] ?? 'N/A';
    String busName = data["bus"]?[0]?[1] ?? 'N/A';
    double latitude = double.tryParse(data["latitude"]?[0]?[1] ?? '') ?? 0.0;
    double longitude = double.tryParse(data["longitude"]?[0]?[1] ?? '') ?? 0.0;
    double bearing =
        double.tryParse(data["bearingCustomer"]?[0]?[1] ?? '') ?? 0.0;
    double speed = double.tryParse(data["speed"]?[0]?[1] ?? '') ?? 0.0;
    String direction = data["direction"]?[0]?[1] ?? '';
    String departureTime = data['departureTime']?[0]?[1] ?? '';
    String showDepartureTime = data['showDepartureTime']?[0]?[1] ?? '';
    String routeDirection = data['routeDirection']?[0]?[1] ?? '';
    String closestBusStop = data['closestBusStopToPubDevice']?[0]?[1] ?? '';
    String etaToNextBusStop = data['etaToNextBusStop']?[0]?[1] ?? '';

    // _logger.i(data);
    print('busName: $busName');
    print('closestBusStop: $closestBusStop');
    print('showDepartureTime: $showDepartureTime');
    print('departureTime: $departureTime\n\n');

    final existingBusIndex =
        state.indexWhere((device) => device.busName == busName);

    if (existingBusIndex != -1) {
      // Bus object exists, update existing data.
      state[existingBusIndex].aid = aid;
      state[existingBusIndex].latitude = latitude;
      state[existingBusIndex].longitude = longitude;
      state[existingBusIndex].bearing = bearing;
      state[existingBusIndex].speed = speed;
      state[existingBusIndex].direction = direction;
      state[existingBusIndex].departureTime = departureTime;
      state[existingBusIndex].showDepartureTime = showDepartureTime;
      state[existingBusIndex].closestBusStop = closestBusStop;
      state[existingBusIndex].routeDirection = routeDirection;
      state[existingBusIndex].etaToNextBusStop = etaToNextBusStop;
      return;
    }

    PublisherTelemetry publisherTelemetry = PublisherTelemetry(
      aid: aid,
      busName: busName,
      bearing: bearing,
      direction: direction,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      departureTime: departureTime,
      showDepartureTime: showDepartureTime,
      routeDirection: routeDirection,
      closestBusStop: closestBusStop,
      etaToNextBusStop: etaToNextBusStop,
    );

    state.add(publisherTelemetry);
  }
}

final telemetryDevicesProvider =
    StateNotifierProvider<TelemetryDevicesNotifier, List<PublisherTelemetry>>(
  (reference) {
    return TelemetryDevicesNotifier();
  },
);
