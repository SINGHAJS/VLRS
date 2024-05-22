import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:lottie/lottie.dart';
import 'package:vlrs/model/bus_stop.dart';

class UiETA {
  ///
  /// This function returns a container ui show the departure information.
  ///
  /// Param: [busName], name of bus
  /// /// Param: [departureTime], time of departure
  ///
  /// Return: Widget, Container.
  static Container showDepartureETAContainerUI(
      String busName, String? departureTime) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.directions_bus,
              color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            ),
            const SizedBox(width: 8.0),
            Text(
              busName,
              style: const TextStyle(
                color: AppColours.BACKGROUND_PRIMARY_COLOUR,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            ),
            const SizedBox(width: 4.0),
            Text(
              ' Departing in $departureTime',
              style: const TextStyle(
                color: AppColours.BACKGROUND_PRIMARY_COLOUR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // static Container showDepartureETAContainerUI(
  //     String busName, String? departureTime) {
  //   return Container(
  //     decoration: const BoxDecoration(color: Colors.black),
  //     child: ListTile(
  //       title: Row(
  //         children: <Widget>[
  //           const Icon(
  //             Icons.directions_bus,
  //             color: AppColours.TEXT_SECONDARY_COLOR,
  //           ),
  //           Text(' $busName',
  //               style: const TextStyle(
  //                   color: AppColours.BACKGROUND_SECONDARY_COLOUR)),
  //         ],
  //       ),
  //       subtitle: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             Icons.access_time,
  //             color: AppColours.TEXT_SECONDARY_COLOR,
  //           ),
  //           Text(
  //             ' Departing in $departureTime',
  //             style: const TextStyle(
  //                 color: AppColours
  //                     .TEXT_SECONDARY_COLOR), // Keep the original color
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  ///
  /// This function returns a container ui show the ETA information.
  ///
  /// Param: [busName], name of bus
  /// Param: [distanceInKms], distance in kilometers
  /// Param: [estimateArrivalTime], estimate time of arrival
  ///
  /// Return: Widget, Container.
  ///
  // static Container showETAInfoContainerUI(
  //     String busName, String? distanceInKms, String? estimateArrivalTime) {
  //   return Container(
  //     decoration: const BoxDecoration(
  //       color: AppColours.BACKGROUND_PRIMARY_COLOUR,
  //     ),
  //     child: ListTile(
  //       title: Row(
  //         children: <Widget>[
  //           const Icon(
  //             Icons.directions_bus,
  //             color: AppColours.TEXT_SECONDARY_COLOR,
  //           ),
  //           Text(' $busName',
  //               style: const TextStyle(
  //                   color: AppColours.BACKGROUND_SECONDARY_COLOUR)),
  //         ],
  //       ),
  //       subtitle: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           const Icon(
  //             Icons.location_on,
  //             color: AppColours.TEXT_SECONDARY_COLOR,
  //           ),
  //           Text(
  //             '$distanceInKms KMs ',
  //             style: const TextStyle(color: AppColours.TEXT_SECONDARY_COLOR),
  //           ),
  //           const Icon(Icons.access_time,
  //               color: AppColours.TEXT_SECONDARY_COLOR),
  //           Text(
  //             '  $estimateArrivalTime',
  //             style: const TextStyle(color: AppColours.TEXT_SECONDARY_COLOR),
  //           )
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Row(
          children: <Widget>[
            const Icon(
              Icons.directions_bus,
              color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            ),
            const SizedBox(width: 8.0),
            Text(
              busName,
              style: const TextStyle(
                color: AppColours.BACKGROUND_PRIMARY_COLOUR,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        subtitle: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            ),
            const SizedBox(width: 4.0),
            Text(
              '$distanceInKms KMs',
              style: const TextStyle(
                color: AppColours.BACKGROUND_PRIMARY_COLOUR,
              ),
            ),
            const SizedBox(width: 16.0),
            const Icon(
              Icons.access_time,
              color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            ),
            const SizedBox(width: 4.0),
            Text(
              estimateArrivalTime ?? '',
              style: const TextStyle(
                color: AppColours.BACKGROUND_PRIMARY_COLOUR,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  /// This function returns an alertdialog ui show "No Buses Scheduled" message.
  ///
  /// Param: [busStopName], name of bus stop
  ///
  /// Return: Widget, AlertDialog.
  ///
  static SizedBox showNoBusesScheduledMessage(String busStopName) {
    return SizedBox(
      width: 300,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Text(
            "No Buses Scheduled",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          SizedBox(
            width: 300,
            height: 150,
            child: Lottie.asset('assets/animations/bus_motion.json'),
          ),
        ],
      ),
    );
  }
}
