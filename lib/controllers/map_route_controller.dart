import 'package:vlrs/model/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:vlrs/model/publisher_telemetry.dart';

class MapRouteController {
  ///
  /// This functions is responsible for handling the onBusStopMarker event. It displays the
  /// name of the stop, along with the details of the vehicle such as its distance from
  /// the stop and the time it will take to reach the stop.
  ///
  /// Param: [context], the context
  /// Param: [busStop], the stop object
  /// Param: [publisherTelemetry], the publisher telemetry object
  ///
  /// Return Widget, ShowDialog
  ///
  Future<dynamic> onBusStopMarkerHandler(BuildContext context, BusStop busStop,
      PublisherTelemetry publisherTelemetry) {
    final Geodesy geodesy = Geodesy();

    final num distance = geodesy.distanceBetweenTwoGeoPoints(
        LatLng(busStop.latitude, busStop.longitude),
        LatLng(publisherTelemetry.latitude, publisherTelemetry.longitude));

    final double distanceInKm = distance / 1000;
    final double estimateArrivalTime = (distanceInKm /
        (publisherTelemetry.speed < 0 ? publisherTelemetry.speed : 50));

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(busStop.name),
          content: SizedBox(
              width: 300,
              height: 200,
              child: Column(
                children: [
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: AppColours.BACKGROUND_PRIMARY_COLOUR,
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.directions_bus,
                          color: AppColours.TEXT_SECONDARY_COLOR,
                        ),
                        Text(
                          publisherTelemetry.busName,
                          style: const TextStyle(
                              color: AppColours.TEXT_SECONDARY_COLOR),
                        ),
                        const Icon(
                          Icons.location_on,
                          color: AppColours.TEXT_SECONDARY_COLOR,
                        ),
                        Text(
                          '${distanceInKm.toStringAsFixed(1)} KMs',
                          style: const TextStyle(
                              color: AppColours.TEXT_SECONDARY_COLOR),
                        ),
                        const Icon(
                          Icons.access_time,
                          color: AppColours.TEXT_SECONDARY_COLOR,
                        ),
                        Text(_formatArrivalTime(estimateArrivalTime),
                            style: const TextStyle(
                                color: AppColours.TEXT_SECONDARY_COLOR))
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }

  ///
  /// <<< Helper Function >>>
  /// This function is a helper function used to format the time.
  /// Param: [estimateArrivalTime], the estiamte time of arrival
  ///
  /// Return String, formatted time
  ///
  String _formatArrivalTime(double estimateArrivalTime) {
    // Calculate hours, minutes, and seconds
    int hours = estimateArrivalTime.toInt();
    int minutes = ((estimateArrivalTime - hours) * 60).toInt();
    int seconds = (((estimateArrivalTime - hours) * 60 - minutes) * 60).toInt();

    // Format the time as "hh:mm:ss"
    String formattedArrivalTime =
        '$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    return formattedArrivalTime;
  }

  ///
  /// <<< Helper Function >>>
  /// This function is a helper function used to ensure that there are always
  /// two digits in the hh:mm:ss format
  /// Param: [n], time value
  ///
  /// Return: String, formatted digit
  ///
  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }
}
