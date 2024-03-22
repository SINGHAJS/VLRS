import 'package:logger/logger.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/ui/eta_ui.dart';
import 'package:vlrs/utils/json_utils.dart';

class MapRouteController {
  final Logger _logger = Logger();
  final List<ETA> _etaList = [];
  final JsonUtils _jsonUtils = JsonUtils();

  final String _busStopFilePath = 'assets/coordinates/BusStopCoordinates.json';
  final String _busStopForwardCoordinatesFile =
      'assets/coordinates/ForwardBusStopCoordinates.json';
  final String _busStopBackwardCoordinatesFile =
      'assets/coordinates/BackwardBusStopCoordinates.json';

  List<BusStop> _busStopList = [];
  List<BusStop> _forwardBusStopList = [];
  List<BusStop> _backwardBusStopList = [];

  ///
  /// This function is assigns the lists of the bus stops.
  ///
  /// Return void.
  ///
  void _initBusLists() async {
    if (_busStopList.isEmpty) {
      _busStopList = await _jsonUtils.readBusStopDataFromJson(_busStopFilePath);
    }

    if (_forwardBusStopList.isEmpty) {
      _forwardBusStopList = await _jsonUtils
          .readBusStopDataFromJson(_busStopForwardCoordinatesFile);
    }
    if (_backwardBusStopList.isEmpty) {
      _backwardBusStopList = await _jsonUtils
          .readBusStopDataFromJson(_busStopBackwardCoordinatesFile);
    }
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
  Future<void> getETAList(
      BusStop busStop, List<PublisherTelemetry> publisherTelemetry) async {
    for (PublisherTelemetry publisherTelemetry in publisherTelemetry) {
      if (publisherTelemetry.showDepartureTime == 'Yes' &&
          publisherTelemetry.departureTime !=
              '00:00:00') // Show departure time is showDepartureTime is true
      {
        String busName = publisherTelemetry.busName;
        String departureTime = publisherTelemetry.departureTime;

        // Define the ETA Model
        ETA eta = ETA(
          busStopName: busStop.name,
          busName: busName,
          departureTime: departureTime,
          showDepartureTime: true,
        );

        final existingETAIndex = _etaList.indexWhere(
            (element) => element.busName == publisherTelemetry.busName);

        if (existingETAIndex != -1) {
          // Update existing entry data
          _etaList[existingETAIndex].departureTime = eta.departureTime;
          _etaList[existingETAIndex].showDepartureTime = eta.showDepartureTime;
          return;
        }

        // Add new entry of ETA
        _etaList.add(eta);
      } else if (publisherTelemetry.showDepartureTime == 'No' ||
          publisherTelemetry.departureTime ==
              '00:00:00') // Show ETA is showDepartureTime is false
      {
        try {
          // Get the total distance between two bus stops
          double totalDistanceBetween = _getTotalDistanceBetweenPubAndStop(
              publisherTelemetry, _busStopList, busStop);

          // Calculate the estimate time of arrival based on the speed of the
          // publisher device.
          double estimateTimeOfArrivalFromAddedDistance =
              (totalDistanceBetween /
                  (publisherTelemetry.speed > 0
                      ? publisherTelemetry.speed
                      : 50));

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
            _etaList[existingETAIndex].estimateArrivalTime =
                eta.estimateArrivalTime;
            _etaList[existingETAIndex].distanceInKms = eta.distanceInKms;
            _etaList[existingETAIndex].showDepartureTime =
                eta.showDepartureTime;
            continue;
          }

          // Add new entry of ETA
          _etaList.add(eta);
        } catch (e) {
          _logger.e('Error: $e');
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
  /// This function is responsible for calculating the closest bus stop to the
  /// publisher device.
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

    print(
        '\n(Finding) Finding closest Bus Stop for ${publisherTelemetry.busName}');
    for (BusStop bStop in busStopsList) {
      num currentDistance = geodesy.distanceBetweenTwoGeoPoints(
          LatLng(publisherTelemetry.latitude, publisherTelemetry.longitude),
          LatLng(bStop.latitude, bStop.longitude));
      double currentDistanceInKms = (currentDistance / 1000);

      if (currentDistanceInKms < distance) {
        distance = currentDistanceInKms;
        closestBusStop = bStop;
        print('[(Iteration) Closest Bus Stop: ${closestBusStop.name}]');
      }
    }

    print('[(Return) Closest Bus Stop ${closestBusStop.name}]');
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
      List<BusStop> backwardBbusStopsList) {
    late BusStop closestBusStop;

    if (publisherTelemetry.routeDirection == 'forward') {
      print('\n[Using Forward Bus Stop Data]');
      closestBusStop = _getClosestBusStopToPubDevice(
          forwardBusStopsList, publisherTelemetry);
    } else if (publisherTelemetry.routeDirection == 'backward') {
      print('\n[Using Backward Bus Stop Data]');
      closestBusStop = _getClosestBusStopToPubDevice(
          backwardBbusStopsList, publisherTelemetry);
    }

    // Assign the first closest bus stop to the publisher device if it is initially null
    if (publisherTelemetry.closestBusStop == null) {
      print(
          '(First Assignment) New Closest BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}');
      return closestBusStop;
    }

    // If the publisher device is not null, then only assign the bus stop as the closest bus
    // stop if it is in sequence.
    if (publisherTelemetry.closestBusStop != null) {
      // Convert the bus stop names into an integer value
      int newClosestBusStopIntegerValue =
          closestBusStop.name == 'S/E' ? 0 : int.parse(closestBusStop.name);
      int currentClosestBusStopIntegerValue =
          publisherTelemetry.closestBusStop!.name == 'S/E'
              ? 0
              : int.parse(publisherTelemetry.closestBusStop!.name);

      // Check if the closest bus stop found is the next bus stop in sequence
      // If true, assign the bus stop as the closest bus stop the the publisher device
      if (newClosestBusStopIntegerValue ==
          currentClosestBusStopIntegerValue + 1) {
        print(
            '[(New Assignment) BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}]');
        return closestBusStop;
      }

      // Check the end case of the route
      // If the closest bus stop is the end bus stop and the current closest bus stop
      // assigned is 17 (last bus stop), then assign this bus stop as the closest bus stop
      // to the publisher device
      if (newClosestBusStopIntegerValue == 0 &&
          currentClosestBusStopIntegerValue == 17) {
        print(
            '[(New Assignment) BusStop = ${closestBusStop.name} | BusName = ${publisherTelemetry.busName}]');
        return closestBusStop;
      }
    }

    // If none of the above conditions are true, then return its current state of the closest bus stop
    print(
        '[(Main Return) No New Bus Stop Assignment Needed | BusStop = ${publisherTelemetry.closestBusStop!.name} | BusName = ${publisherTelemetry.busName} ]');
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

    // Find the index of the closest bus stop to the publisher device
    for (int i = 0; i < busStopsList.length; i++) {
      if (busStopsList[i].name == publisherTelemetry.closestBusStop!.name) {
        index = i;
      }
    }

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

    return (totalDistance / 1000);
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
  Future<dynamic> onBusStopMarkerHandler(BuildContext context, BusStop busStop,
      List<PublisherTelemetry> publisherTelemetry) {
    _initBusLists();

    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder(
          future: getETAList(busStop, publisherTelemetry),
          builder: ((context, snapshot) {
            // Data has been loaded
            if (snapshot.connectionState == ConnectionState.done) {
              return AlertDialog(
                title: Text('Bus Stop: ${busStop.name}'),
                content: SizedBox(
                  width: 300,
                  height: 200,
                  child: ListView.builder(
                    itemCount: _etaList.length,
                    itemBuilder: (context, index) {
                      if (_etaList[index].showDepartureTime) {
                        return UiETA.showDepartureETAContainerUI(
                            _etaList[index].busName,
                            _etaList[index].departureTime);
                      }

                      return UiETA.showETAInfoContainerUI(
                          _etaList[index].busName,
                          _etaList[index].distanceInKms,
                          _etaList[index].estimateArrivalTime);
                    },
                  ),
                ),
              );
            }
            // Waiting for data
            else {
              return AlertDialog(
                title: Text('Bus Stop: ${busStop.name}'),
                content: const SizedBox(
                  width: 300,
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }
          }),
        );
      },
    );
  }
}
