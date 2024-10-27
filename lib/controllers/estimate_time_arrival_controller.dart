import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/open_route_service_info.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/services/open_route_service.dart';
import 'package:vlrs/model/bus_stop_data.dart';

class EstimateTimeArrivalController {
  Future<List<ETA>> getListOfETAs(
      BusStop clickedBusStop,
      List<PublisherTelemetry> publisherTelemetryList,
      List<ETA> listOfETAs,
      List<BusStop> busStopList) async {
    listOfETAs = [];
    try {
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

          _updateOrAddETA(departureETA, listOfETAs);
        } else if (publisherTelemetry.showDepartureTime == 'No' ||
            publisherTelemetry.departureTime == '00:00:00') {
          int clickedBusStopIntegerValue =
              _convertBusStopNumberToInt(clickedBusStop.name);
          int pubDeviceClosestBusStopToPubIntegerValue =
              _convertBusStopNumberToInt(publisherTelemetry.closestBusStop);

          if (clickedBusStopIntegerValue <=
              pubDeviceClosestBusStopToPubIntegerValue) {
            // Remove the entry of the publisher device entry in the list for
            // clicked bus stop as it has been passed by the publisher device.
            listOfETAs = _removePubDeviceIfPassedBStop(
                clickedBusStop, publisherTelemetry, listOfETAs);
          } else {
            final targetBusStopsCoordinates =
                _getBStopCoordinatesListFromOriginToDestination(
                    publisherTelemetry, clickedBusStop, busStopList);

            final openRouteServiceInfo =
                await OpenRouteService.getORSInfoObject(
                    targetBusStopsCoordinates);

            final closestBusStopToPubDevice = busStopList.firstWhere(
                (busStop) => busStop.name == publisherTelemetry.closestBusStop);

            final distanceBetweenPubDevAndClosestBusStop =
                await OpenRouteService.getTotalDistanceFromPointToPoint([
              [publisherTelemetry.longitude, publisherTelemetry.latitude],
              [
                closestBusStopToPubDevice.longitude,
                closestBusStopToPubDevice.latitude
              ]
            ]);

            // Note: Below code may be used to potentially improve the accurcay
            // of the distance provided for show dialog.
            final finalCalculatedETADistance = (openRouteServiceInfo.distance! -
                distanceBetweenPubDevAndClosestBusStop);

            ETA eta = ETA(
              aid: publisherTelemetry.aid,
              busStopName: clickedBusStop.name,
              busName: publisherTelemetry.busName,
              estimateArrivalTime: openRouteServiceInfo.estimateTimeOfArrival,
              // distanceInKms: finalCalculatedETADistance.toStringAsFixed(2),
              distanceInKms: openRouteServiceInfo.distance?.toStringAsFixed(2),
              showDepartureTime: false,
            );

            _updateOrAddETA(eta, listOfETAs);
          }
        }
      }
    } catch (e) {
      print("Error fetching ETAs: $e");
    }

    return listOfETAs;
  }

  void _updateOrAddETA(ETA eta, List<ETA> listOfETAs) {
    final existingIndex = listOfETAs.indexWhere((cETA) => cETA.aid == eta.aid);

    if (existingIndex != -1) {
      // Update existing entry
      listOfETAs[existingIndex] = eta;
    } else {
      // Add new entry
      listOfETAs.add(eta);
    }
  }

  List<ETA> _removePubDeviceIfPassedBStop(BusStop clickedBusStop,
      PublisherTelemetry publisherTelemetry, List<ETA> listOfETAs) {
    return listOfETAs
        .where((pubDeviceClosestBusStop) =>
            pubDeviceClosestBusStop.busStopName == clickedBusStop.name)
        .toList();

    // if (closestBusStopToPubIntegerValue >= currentClosestBusStopIntegerValue) {
    //   final containsETA =
    //       listOfETAs.any((cETA) => cETA.aid == publisherTelemetry.aid);

    //   if (containsETA) {
    //     listOfETAs = listOfETAs
    //         .where((cETA) => cETA.aid != publisherTelemetry.aid)
    //         .toList();
    //     return true;
    //   }
    // }
  }

  ///
  /// Gets and returns list of coordinates from the origin bus stop to the
  /// destination bus stop.
  ///
  /// @param [currPubDevice], current bus stop closest to the publisher device.
  /// @param [clickedBusStop], bus stop object that has been clicked.
  /// @param [busStopList], list of all bus stops.
  ///
  /// @return [busStopCoordinates], List<List<double>>, containing all the coordinates.
  ///
  List<List<double>> _getBStopCoordinatesListFromOriginToDestination(
      PublisherTelemetry currPubDevice,
      BusStop clickedBusStop,
      List<BusStop> busStopList) {
    List<List<double>> busStopCoordinates = [];

    // Find the index of the closest bus stop the publisher device.
    int curBusStopIndex = busStopList
        .indexWhere((busStop) => busStop.name == currPubDevice.closestBusStop);

    if (curBusStopIndex == -1) {
      print(
          'Could not find bus stop with the name: ${currPubDevice.closestBusStop}');
    }

    // Start adding bus stops from the index of the closest bus stop to the
    // publisher device to the bus stop that is clicked.
    for (int i = curBusStopIndex; i < busStopList.length; i++) {
      busStopCoordinates
          .add([busStopList[i].longitude, busStopList[i].latitude]);
      if (busStopList[i].name == clickedBusStop.name) return busStopCoordinates;
    }

    // This loop is run when the bus stop before the publisher device's closest
    // bus stop. Therefore, it has to do a loop around.
    // Note: This value may not be used as current implementatation is set to not
    // display ETA for bus stops that the publisher device has passed. 02/08/24
    for (int i = 0; i < busStopList.length; i++) {
      busStopCoordinates
          .add([busStopList[i].longitude, busStopList[i].latitude]);
      if (busStopList[i].name == clickedBusStop.name) return busStopCoordinates;
    }

    return busStopCoordinates;
  }

  int _convertBusStopNumberToInt(String name) {
    if (name == 'S/E') {
      return 0;
    }

    try {
      return int.parse(name);
    } catch (e) {
      return -1;
    }
  }
}
