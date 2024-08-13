import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class EstimateTimeArrivalNotifer extends StateNotifier<List<ETA>> {
  EstimateTimeArrivalNotifer() : super([]);

  List<ETA> getListOfETAs(
      BusStop clickedBusStop, List<PublisherTelemetry> publisherTelemetryList) {
    List<ETA> listOfETAs = [];

    for (PublisherTelemetry publisherTelemetry in publisherTelemetryList) {
      if (publisherTelemetry.showDepartureTime == 'Yes' &&
          publisherTelemetry.departureTime != '00:00:00') {
        // Define Departure ETA

        ETA departureETA = ETA(
          aid: publisherTelemetry.aid,
          busStopName: clickedBusStop.name,
          busName: publisherTelemetry.busName,
          departureTime: publisherTelemetry.departureTime,
          showDepartureTime: true,
        );

        _addPubDeviceETA(departureETA);
      } else if (publisherTelemetry.showDepartureTime == 'No' ||
          publisherTelemetry.departureTime == '00:00:00') {
        final isCurrentETARemoved =
            _removePubDeviceIfPassedBStop(clickedBusStop, publisherTelemetry);

        if (!isCurrentETARemoved) {
          ETA eta = ETA(
            aid: publisherTelemetry.aid,
            busStopName: clickedBusStop.name,
            busName: publisherTelemetry.busName,
            estimateArrivalTime: 'N/A',
            distanceInKms: 'N/A',
            showDepartureTime: false,
          );

          _addPubDeviceETA(eta);
        }
      }
    }

    return listOfETAs;
  }

  void _addPubDeviceETA(ETA eta) {
    final containsETA = state.contains((cETA) => cETA.aid == eta.aid);

    if (containsETA) {
      state = state.where((cETA) => cETA.aid != eta.aid).toList();
    }

    state = [...state, eta];
  }

  bool _removePubDeviceIfPassedBStop(
      BusStop busStop, PublisherTelemetry publisherTelemetry) {
    int currentClosestBusStopIntegerValue =
        _convertBusStopNumberToInt(busStop.name);
    int closestBusStopToPubIntegerValue =
        _convertBusStopNumberToInt(publisherTelemetry.closestBusStop);

    if (closestBusStopToPubIntegerValue >= currentClosestBusStopIntegerValue) {
      final containsETA =
          state.contains((cETA) => cETA.aid == publisherTelemetry.aid);

      if (containsETA) {
        state =
            state.where((cETA) => cETA.aid != publisherTelemetry.aid).toList();
        return true;
      }
    }

    return false;
  }

  ///
  /// <<< Helper Function >>>
  /// This function is a helper function used to convert the name of the bus stop
  /// into an integer value.
  ///
  /// Param: [busStop]], BusStop
  ///
  /// Return: int, integer representation of the bus stop name
  ///
  int _convertBusStopNumberToInt(String name) {
    return name == 'S/E' ? 0 : int.parse(name);
  }
}

final estimateTimeArrivalProvider =
    StateNotifierProvider<EstimateTimeArrivalNotifer, List<ETA>>(
  (reference) {
    return EstimateTimeArrivalNotifer();
  },
);
