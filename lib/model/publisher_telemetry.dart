import 'package:vlrs/model/bus_stop.dart';

class PublisherTelemetry {
  double bearing;
  String direction;
  double latitude;
  double longitude;
  double speed;
  String busName;
  String departureTime;
  String showDepartureTime;
  BusStop? closestBusStop;
  String routeDirection;

  PublisherTelemetry({
    this.busName = 'undefined',
    required this.bearing,
    required this.direction,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.departureTime,
    required this.showDepartureTime,
    this.closestBusStop,
    this.routeDirection = 'forward',
  });
}
