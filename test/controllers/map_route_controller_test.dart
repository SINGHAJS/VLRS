import 'package:flutter_test/flutter_test.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/utils/json_utils.dart';

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Initialize Flutter binding for tests

  const String busStopFilePath = 'assets/coordinates/BusStopCoordinates.json';
  const String busStopForwardCoordinatesFile =
      'assets/coordinates/ForwardBusStopCoordinates.json';
  const String busStopBackwardCoordinatesFile =
      'assets/coordinates/BackwardBusStopCoordinates.json';

  final MapRouteController mapRouteController = MapRouteController();
  final JsonUtils jsonUtils = JsonUtils();

  group('Test: Bus Stop Assignment', () {
    test('Test Closest Bus Assignment #1', () async {
      // No Bus Stop Assigned
      List<BusStop> busStopsList =
          await jsonUtils.readBusStopDataFromJson(busStopFilePath);
      List<BusStop> forwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopForwardCoordinatesFile);
      List<BusStop> backwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopBackwardCoordinatesFile);

      PublisherTelemetry publisherTelemetry = PublisherTelemetry(
          bearing: 0.0,
          direction: "forward",
          latitude: -36.8558239,
          longitude: 174.7650926,
          speed: 50.0,
          departureTime: "",
          showDepartureTime: "No");

      BusStop? newBusStop =
          mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              publisherTelemetry,
              busStopsList,
              forwardBusStopList,
              backwardBusStopList);

      expect(newBusStop!.name, "S/E");
    });

    test('Test Closest Bus Assignment #2', () async {
      // Test the next bus stop assignment in sequence
      List<BusStop> busStopsList =
          await jsonUtils.readBusStopDataFromJson(busStopFilePath);
      List<BusStop> forwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopForwardCoordinatesFile);
      List<BusStop> backwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopBackwardCoordinatesFile);

      BusStop bStop = BusStop(
          name: "S/E",
          latitude: -36.78012,
          longitude: .99216,
          distanceToNextStop: 1447);

      PublisherTelemetry publisherTelemetry = PublisherTelemetry(
        bearing: 0.0,
        direction: "forward",
        latitude: -36.78125,
        longitude: 175.007,
        speed: 50.0,
        departureTime: "",
        showDepartureTime: "No",
        closestBusStop: bStop,
      );

      BusStop? newBusStop =
          mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              publisherTelemetry,
              busStopsList,
              forwardBusStopList,
              backwardBusStopList);

      expect(newBusStop!.name, "1");
    });

    test('Test Closest Bus Assignment #3', () async {
      // Test the next bus stop assignment in sequence
      List<BusStop> busStopsList =
          await jsonUtils.readBusStopDataFromJson(busStopFilePath);
      List<BusStop> forwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopForwardCoordinatesFile);
      List<BusStop> backwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopBackwardCoordinatesFile);

      BusStop bStop = BusStop(
          name: "2",
          latitude: -36.78316,
          longitude: 175.01086,
          distanceToNextStop: 3731);

      PublisherTelemetry publisherTelemetry = PublisherTelemetry(
        bearing: 0.0,
        direction: "forward",
        latitude: -36.78125,
        longitude: 175.007,
        speed: 50.0,
        departureTime: "",
        showDepartureTime: "No",
        closestBusStop: bStop,
      );

      BusStop? newBusStop =
          mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              publisherTelemetry,
              busStopsList,
              forwardBusStopList,
              backwardBusStopList);

      expect(newBusStop!.name, "2");
    });

    test('Test Closest Bus Assignment #4', () async {
      // Test the next bus stop assignment in sequence
      List<BusStop> busStopsList =
          await jsonUtils.readBusStopDataFromJson(busStopFilePath);
      List<BusStop> forwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopForwardCoordinatesFile);
      List<BusStop> backwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopBackwardCoordinatesFile);

      BusStop bStop = BusStop(
          name: "2",
          latitude: -36.78316,
          longitude: 175.01086,
          distanceToNextStop: 3731);

      PublisherTelemetry publisherTelemetry = PublisherTelemetry(
        bearing: 0.0,
        direction: "forward",
        latitude: -36.79699,
        longitude: 175.03212,
        speed: 50.0,
        departureTime: "",
        showDepartureTime: "No",
        closestBusStop: bStop,
      );

      BusStop? newBusStop =
          mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              publisherTelemetry,
              busStopsList,
              forwardBusStopList,
              backwardBusStopList);

      expect(newBusStop!.name, "3");
    });

    test('Test Closest Bus Assignment #5', () async {
      // Test the next bus stop assignment in sequence
      List<BusStop> busStopsList =
          await jsonUtils.readBusStopDataFromJson(busStopFilePath);
      List<BusStop> forwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopForwardCoordinatesFile);
      List<BusStop> backwardBusStopList = await jsonUtils
          .readBusStopDataFromJson(busStopBackwardCoordinatesFile);

      BusStop bStop = BusStop(
          name: "11",
          latitude: -36.81456,
          longitude: 175.08249,
          distanceToNextStop: 2187);

      PublisherTelemetry publisherTelemetry = PublisherTelemetry(
        bearing: 0.0,
        direction: "backward",
        latitude: -36.80916,
        longitude: 175.06174,
        speed: 50.0,
        departureTime: "",
        showDepartureTime: "No",
        closestBusStop: bStop,
      );

      BusStop? newBusStop =
          mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              publisherTelemetry,
              busStopsList,
              forwardBusStopList,
              backwardBusStopList);

      expect(newBusStop!.name, "11");
    });
  });

  group('Test: Bus Stop Name Conversion', () {
    test('Test Bus Stop Name Concersion #1', () async {
      // Test the next bus stop name conversion

      BusStop bStop = BusStop(
          name: "10",
          latitude: -36.81456,
          longitude: 175.08249,
          distanceToNextStop: 2187);

      int bStopInInt = mapRouteController.convertBusStopNumberToInt(bStop);

      expect(bStopInInt, 10);
    });

    test('Test Bus Stop Name Conversion #2', () async {
      // Test the next bus stop name conversion

      BusStop bStop = BusStop(
          name: "S/E",
          latitude: -36.81456,
          longitude: 175.08249,
          distanceToNextStop: 2187);

      int bStopInInt = mapRouteController.convertBusStopNumberToInt(bStop);

      expect(bStopInInt, 0);
    });
  });

  group('Test: ETA', () {
    test('Test ETA #1', () {
      double distance = 100;
      double speed = 50;

      double actualETA = mapRouteController.calculateETA(distance, speed);
      String formattedETA = mapRouteController.formatArrivalTime(actualETA);

      expect(formattedETA, equals('2:00:00'));
    });

    test('Test ETA #2', () {
      double distance = 0;
      double speed = 60;

      double actualETA = mapRouteController.calculateETA(distance, speed);
      String formattedETA = mapRouteController.formatArrivalTime(actualETA);

      expect(formattedETA, equals('0:00:00'));
    });

    test('Test ETA #3', () {
      double distance = 150;
      double speed = 200;

      double actualETA = mapRouteController.calculateETA(distance, speed);
      String formattedETA = mapRouteController.formatArrivalTime(actualETA);

      expect(formattedETA, equals('0:45:00'));
    });
  });
}
