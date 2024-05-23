import 'package:logger/logger.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/services/tomtom_service.dart';
import 'package:vlrs/ui/eta_ui.dart';

class MapRouteController {
  final Logger _logger = Logger();
  final List<ETA> _etaList = [];
  List<BusStop> _busStopList = [];

  ///
  /// This function is assigns the lists of the bus stops.
  ///
  /// Return void.
  ///
  void _initBusLists(List<BusStop> busStopsList) {
    _busStopList = busStopsList;
  }

  ///
  /// This function is responsible creating the list of ETAs to show in the
  /// showDialog.
  ///
  /// Param: [busStop], the curent bus stop
  /// Param: [publisherTelemetry], the list of publisher devices
  ///
  /// Return Future, void.
  ///
  void getETAList(
      BusStop busStop, List<PublisherTelemetry> publisherTelemetry) {
    for (PublisherTelemetry publisherTelemetry in publisherTelemetry) {
      if (publisherTelemetry.showDepartureTime == 'Yes' &&
          publisherTelemetry.departureTime !=
              '00:00:00') // Show departure time is showDepartureTime is true
      {
        // Define the ETA Model
        ETA eta = ETA(
          busStopName: busStop.name,
          busName: publisherTelemetry.busName,
          departureTime: publisherTelemetry.departureTime,
          showDepartureTime: true,
        );

        // Find the index of existing ETA in the list.
        final existingETAIndex = _etaList.indexWhere(
            (element) => element.busName == publisherTelemetry.busName);

        if (existingETAIndex != -1) {
          // Update existing entry data
          _etaList[existingETAIndex].departureTime = eta.departureTime;
          _etaList[existingETAIndex].showDepartureTime = eta.showDepartureTime;
          continue;
        }

        // Add new entry of ETA
        _etaList.add(eta);
      } else if (publisherTelemetry.showDepartureTime == 'No' ||
          publisherTelemetry.departureTime ==
              '00:00:00') // Show ETA is showDepartureTime is false
      {
        // Get the total distance between two bus stops
        double totalDistanceBetween = _getTotalDistanceBetweenPubAndStop(
            publisherTelemetry, _busStopList, busStop);

        int currentClosestBusStopIntegerValue =
            _convertBusStopNumberToInt(busStop);
        int closestBusStopToPubIntegerValue =
            _convertBusStopNumberToInt(publisherTelemetry!.closestBusStop);

        if (closestBusStopToPubIntegerValue >
                currentClosestBusStopIntegerValue ||
            totalDistanceBetween <= 0) {
          _etaList
              .removeWhere((eta) => eta.busName == publisherTelemetry.busName);
          continue;
        }

        // Calculate the estimate time of arrival based on the speed of the
        // publisher device.
        double estimateTimeOfArrivalFromAddedDistance =
            (totalDistanceBetween / publisherTelemetry.speed);

        String busName = publisherTelemetry.busName;
        String distanceInKms = totalDistanceBetween.toStringAsFixed(2);
        String formattedArrivalTime =
            _formatArrivalTime(estimateTimeOfArrivalFromAddedDistance);

        // Define the ETA Model
        ETA eta = ETA(
          busStopName: busStop.name,
          busName: busName,
          estimateArrivalTime: formattedArrivalTime,
          distanceInKms: distanceInKms,
          showDepartureTime: false,
        );

        final existingETAIndex = _etaList.indexWhere(
            (element) => element.busName == publisherTelemetry.busName);

        if (existingETAIndex != -1) {
          // Update existing entry data
          _etaList.removeAt(existingETAIndex);
          _etaList.add(eta);
        } else {
          // Add new entry of ETA
          _etaList.add(eta);
        }
      }
    }
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

  ///
  /// <<< Helper Function >>>
  /// This function is a helper function used to convert the name of the bus stop
  /// into an integer value.
  ///
  /// Param: [busStop]], BusStop
  ///
  /// Return: int, integer representation of the bus stop name
  ///
  int _convertBusStopNumberToInt(BusStop? busStop) {
    return busStop!.name == 'S/E' ? 0 : int.parse(busStop.name);
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
  /// This function is responsible for iterating over all of the bus stops and
  /// calculating the closest bus stop to the publisher device.
  ///
  /// Param: [busStopsList], the list of bus stops
  /// Param: [publisherTelemetry], the current publisher device
  ///
  /// Return BusStop, closest bus stop to the publisher device.
  ///
  BusStop _getClosestBusStopToPubDevice(
      List<BusStop> busStopsList, PublisherTelemetry publisherTelemetry) {
    final Geodesy geodesy = Geodesy();
    double distance = 999;
    late BusStop closestBusStop;

    for (BusStop bStop in busStopsList) {
      num currentDistance = geodesy.distanceBetweenTwoGeoPoints(
          LatLng(publisherTelemetry.latitude, publisherTelemetry.longitude),
          LatLng(bStop.latitude, bStop.longitude));
      double currentDistanceInKms = (currentDistance / 1000);

      if (currentDistanceInKms < distance) {
        distance = currentDistanceInKms;
        closestBusStop = bStop;
      }
    }
    return closestBusStop;
  }

  ///
  /// This function is responsible for assigning and calculating the closest bus stop to the
  /// publisher device.
  ///
  /// Param: [publisherTelemetry], the current publisher device
  /// Param: [busStopsList], the list of bus stops
  /// Param: [forwardBusStopsList], the list of bus stops in forward direction
  /// Param: [backwardBbusStopsList], the list of bus stops in backward direction
  ///
  /// Return BusStop, closest bus stop to the publisher device.
  ///
  BusStop? assignAndCalculateClosestBusStopToPublisherDevice(
      PublisherTelemetry publisherTelemetry,
      List<BusStop> busStopsList,
      List<BusStop> forwardBusStopsList,
      List<BusStop> backwardBusStopsList) {
    late BusStop closestBusStop;
    final Geodesy geodesy = Geodesy();

    if (publisherTelemetry.routeDirection == 'forward') {
      closestBusStop = _getClosestBusStopToPubDevice(
          forwardBusStopsList, publisherTelemetry);
    } else if (publisherTelemetry.routeDirection == 'backward') {
      closestBusStop = _getClosestBusStopToPubDevice(
          backwardBusStopsList, publisherTelemetry);
    }

    // Assign the first closest bus stop to the publisher device if it is initially null
    if (publisherTelemetry.closestBusStop == null) {
      _logger.i(
          '(First Assignment) New Closest BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}');
      return closestBusStop;
    }

    // If the publisher device is not null, then only assign the bus stop as the closest bus
    // stop if it is in sequence.
    if (publisherTelemetry.closestBusStop != null) {
      // Convert the bus stop names into an integer value
      int newClosestBusStopIntegerValue =
          _convertBusStopNumberToInt(closestBusStop);
      int currentClosestBusStopIntegerValue =
          _convertBusStopNumberToInt(publisherTelemetry.closestBusStop);

      double distanceBetween = geodesy.distanceBetweenTwoGeoPoints(
              LatLng(closestBusStop.latitude, closestBusStop.longitude),
              LatLng(publisherTelemetry.latitude, publisherTelemetry.longitude))
          as double;

      // Check if the closest bus stop found is the next bus stop in sequence
      // If true, assign the bus stop as the closest bus stop the the publisher device

      // Note: the distanceBetween is set to 300 for the purpose of the animation. Since the animation loops of lats and lngs
      // with large differences, the difference between the bus stop and the publisher device is not always less than 100m.
      // However, in a real-life scenario, the difference between the bus stop and the publisher device will definitely be less
      // than 100ms. For the sake of the animation, the placeholder value is set to 300m.
      // USE 100m IN REAL-LIFE SCENARIO.
      if (newClosestBusStopIntegerValue ==
              currentClosestBusStopIntegerValue + 1 &&
          distanceBetween <= 300) {
        _logger.i(
            '[(New Assignment) BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}]');
        return closestBusStop;
      }

      // Check the end case of the route
      // If the closest bus stop is the end bus stop and the current closest bus stop
      // assigned is 17 (last bus stop), then assign this bus stop as the closest bus stop
      // to the publisher device
      if (newClosestBusStopIntegerValue == 0 &&
          currentClosestBusStopIntegerValue == 17 &&
          distanceBetween <= 300) {
        _logger.i(
            '[(New Assignment) BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}]');
        return closestBusStop;
      }
    }

    // If none of the above conditions are true, then return its current state of the closest bus stop
    return publisherTelemetry.closestBusStop;
  }

  ///
  /// This function is responsible for calculating the total distance between the publisher
  /// device and the bus stop that is clicked.
  ///
  /// Param: [publisherTelemetry], the current publisher device
  /// Param: [busStopsList], the list of bus stops
  /// Param: [currentBusStop], the current bus stop clicked
  ///
  /// Return double, total distance in kilometers.
  ///
  double _getTotalDistanceBetweenPubAndStop(
      PublisherTelemetry publisherTelemetry,
      List<BusStop> busStopsList,
      BusStop currentBusStop) {
    double totalDistance = 0.0;
    late int index;
    bool currentBusStopFound = false;
    final Geodesy geodesy = Geodesy();

    // Find the index of the closest bus stop to the publisher device
    for (int i = 0; i < busStopsList.length; i++) {
      if (busStopsList[i].name == publisherTelemetry.closestBusStop!.name) {
        index = i;
      }
    }

    // Calculate the distance from the publisher device to the next bus stop
    double distanceToNextStop = geodesy.distanceBetweenTwoGeoPoints(
          LatLng(publisherTelemetry.latitude, publisherTelemetry.longitude),
          LatLng(publisherTelemetry.closestBusStop!.latitude,
              publisherTelemetry.closestBusStop!.longitude),
        ) /
        1000; // Convert to kilometers

    // Add the total distance of between the bus stops starting from the closest bus stop
    // to the current bus stop.
    while (!currentBusStopFound) {
      for (int i = index; i < busStopsList.length; i++) {
        if (busStopsList[i].name == currentBusStop.name) {
          currentBusStopFound = true;
          break;
        }
        totalDistance += busStopsList[i].distanceToNextStop;
      }

      if (!currentBusStopFound) {
        index = 0;
        currentBusStopFound = false;
      }
    }

    totalDistance = (totalDistance / 1000) - distanceToNextStop;
    _logger.i('Subtracting distance $distanceToNextStop from $totalDistance');

    return (totalDistance);
  }

  ///
  /// This function is responsible for handling the onBusStopMarker event. It displays the
  /// name of the stop, along with the details of the vehicle such as its distance from
  /// the stop and the time it will take to reach the stop.
  ///
  /// Param: [context], the context
  /// Param: [busStop], the bus stop object clicked
  /// Param: [publisherTelemetry], the publisher telemetry object
  ///
  /// Return Future, dynamic.
  ///
  void onBusStopMarkerHandler(BuildContext context, BusStop busStop,
      List<PublisherTelemetry> publisherTelemetry, List<BusStop> busStopsList) {
    _initBusLists(busStopsList);

    getETAList(busStop, publisherTelemetry);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: <Widget>[
              const Icon(Icons.place),
              Text(' ${busStop.name}'),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 200,
            child: _etaList.isEmpty
                ? UiETA.showNoBusesScheduledMessage(busStop.name)
                : ListView.builder(
                    itemCount: _etaList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (_etaList.isEmpty) {
                        print('List Empty!');
                        return UiETA.showNoBusesScheduledMessage(busStop.name);
                      }
                      if (_etaList[index].showDepartureTime == true) {
                        return UiETA.showDepartureETAContainerUI(
                            _etaList[index].busName,
                            _etaList[index].departureTime);
                      }

                      print(
                          '${_etaList[index].busName}, ${_etaList[index].distanceInKms}, ${_etaList[index].estimateArrivalTime}');
                      return UiETA.showETAInfoContainerUI(
                          _etaList[index].busName,
                          _etaList[index].distanceInKms,
                          _etaList[index].estimateArrivalTime);
                    }),
          ),
        );
      },
    );
  }

  ///
  /// <<TEST PURPOSES>>
  ///
  int convertBusStopNumberToInt(BusStop? busStop) {
    return busStop!.name == 'S/E' ? 0 : int.parse(busStop.name);
  }

  ///
  /// <<TEST PURPOSES>>
  ///
  double calculateETA(double distance, double speed) {
    return distance / speed;
  }

  ///
  /// <<TEST PURPOSES>>
  ///
  String formatArrivalTime(double estimateArrivalTime) {
    // Calculate hours, minutes, and seconds
    int hours = estimateArrivalTime.toInt();
    int minutes = ((estimateArrivalTime - hours) * 60).toInt();
    int seconds = (((estimateArrivalTime - hours) * 60 - minutes) * 60).toInt();

    // Format the time as "hh:mm:ss"
    String formattedArrivalTime =
        '$hours:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    return formattedArrivalTime;
  }
}
