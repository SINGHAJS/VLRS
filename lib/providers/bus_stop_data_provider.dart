import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/model/bus_stop_data.dart';
import 'package:vlrs/model/bus_stop.dart';

class BusStopDataNotifier extends StateNotifier<List<BusStopData>> {
  BusStopDataNotifier() : super([]);
  final Logger _logger = Logger();

  ///
  /// This function takes the data snapshot and creates/updates a
  /// [BusStop] object.
  ///
  /// [dataSnapshot] - String value of the snapshot data
  ///
  void addBusStopData(String? dataSnapshot) {
    if (dataSnapshot == null) {
      _logger.w("Data snapshot is null.");
      return; // Exit if the dataSnapshot is null
    }

    // Decode datasnapshot
    final decodedJson = jsonDecode(dataSnapshot);
    if (decodedJson == null || decodedJson.isEmpty) {
      _logger.w("Decoded JSON is null or empty.");
      return; // Exit if json is null or empty
    }

    // Access the busStop data
    final busStopData = decodedJson[1]['data']['busStop'][0][1]['busStops'];

    if (busStopData == null || busStopData.isEmpty) {
      _logger.w("No bus stops found.");
      return; // Exit if busStopData is null or empty
    }

    // Iterate through each bus stop and print the details
    for (var busStop in busStopData) {
      print('Bus Stop Name: ${busStop['bus-stop-name']}');
      print('Latitude: ${busStop['latitude']}');
      print('Longitude: ${busStop['longitude']}');
      print(
          'Distance to Next Stop: ${busStop['distance-to-next-stop']} meters');
      print('---------------------------------------');
    }
  }
}

final busStopDataProvider =
    StateNotifierProvider<BusStopDataNotifier, List<BusStopData>>(
  (reference) {
    return BusStopDataNotifier();
  },
);
