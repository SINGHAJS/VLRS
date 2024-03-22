import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';

class UiETA {
  ///
  /// This function returns a container ui show the departure information.
  ///
  /// Param: [busName], name of bus
  /// /// Param: [departureTime], time of departure
  ///
  /// Return: Widget, Container.
  ///
  static Container showDepartureETAContainerUI(
      String busName, String? departureTime) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
      child: ListTile(
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.directions_bus,
              color: AppColours.TEXT_SECONDARY_COLOR,
            ),
            Text(' $busName',
                style: const TextStyle(
                    color: AppColours.BACKGROUND_SECONDARY_COLOUR)),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.access_time,
              color: AppColours.TEXT_SECONDARY_COLOR,
            ),
            Text(
              ' Departing in $departureTime',
              style: const TextStyle(
                  color: AppColours
                      .TEXT_SECONDARY_COLOR), // Keep the original color
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// This function returns a container ui show the ETA information.
  ///
  /// Param: [busName], name of bus
  /// Param: [distanceInKms], distance in kilometers
  /// Param: [estimateArrivalTime], estimate time of arrival
  ///
  /// Return: Widget, Container.
  ///
  static Container showETAInfoContainerUI(
      String busName, String? distanceInKms, String? estimateArrivalTime) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColours.BACKGROUND_PRIMARY_COLOUR,
      ),
      child: ListTile(
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.directions_bus,
              color: AppColours.TEXT_SECONDARY_COLOR,
            ),
            Text(' $busName',
                style: const TextStyle(
                    color: AppColours.BACKGROUND_SECONDARY_COLOUR)),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: AppColours.TEXT_SECONDARY_COLOR,
            ),
            Text(
              '$distanceInKms KMs ',
              style: const TextStyle(color: AppColours.TEXT_SECONDARY_COLOR),
            ),
            const Icon(Icons.access_time,
                color: AppColours.TEXT_SECONDARY_COLOR),
            Text(
              '  $estimateArrivalTime',
              style: const TextStyle(color: AppColours.TEXT_SECONDARY_COLOR),
            )
          ],
        ),
      ),
    );
  }
}
