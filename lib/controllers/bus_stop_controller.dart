import 'package:logger/logger.dart';
import 'package:vlrs/controllers/estimate_time_arrival_controller.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:flutter/material.dart';
import 'package:vlrs/model/eta.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/ui/eta_ui.dart';

class BusStopController {
  Logger _logger = Logger();
  List<ETA> _listOfETAs = [];
  List<BusStop> _busStopList = [];

  EstimateTimeArrivalController estimateTimeArrivalController =
      EstimateTimeArrivalController();

  void _initBusLists(List<BusStop> busStopsList) {
    _busStopList = busStopsList;
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            width: 300,
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading Bus ETAs..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void onBusStopMarkerHandler(
      BuildContext context,
      BusStop busStop,
      List<PublisherTelemetry> publisherTelemetry,
      List<BusStop> busStopsList) async {
    _initBusLists(busStopsList);

    // Show the loading dialog
    _showLoadingDialog(context);

    // Fetch the ETAs
    _listOfETAs = await estimateTimeArrivalController.getListOfETAs(
        busStop, publisherTelemetry, _listOfETAs, _busStopList);

    // Close the loading dialog
    Navigator.of(context).pop();

    // Show the ETA dialog
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
            child: _listOfETAs.isEmpty
                ? UiETA.showNoBusesScheduledMessage(busStop.name)
                : ListView.builder(
                    itemCount: _listOfETAs.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (_listOfETAs.isEmpty) {
                        print('List Empty!');
                        return UiETA.showNoBusesScheduledMessage(busStop.name);
                      }
                      if (_listOfETAs[index].showDepartureTime == true) {
                        return UiETA.showDepartureETAContainerUI(
                            _listOfETAs[index].busName,
                            _listOfETAs[index].departureTime);
                      }

                      print(
                          '${_listOfETAs[index].busName}, ${_listOfETAs[index].distanceInKms}, ${_listOfETAs[index].estimateArrivalTime}');
                      return UiETA.showETAInfoContainerUI(
                          _listOfETAs[index].busName,
                          _listOfETAs[index].distanceInKms,
                          _listOfETAs[index].estimateArrivalTime);
                    }),
          ),
        );
      },
    );
  }
}
