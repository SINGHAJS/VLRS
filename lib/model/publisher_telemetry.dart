import 'package:vlrs/model/bus_stop.dart';

class PublisherTelemetry {
  String aid;
  double bearing;
  String direction;
  double latitude;
  double longitude;
  double speed;
  String busName;
  String departureTime;
  String showDepartureTime;
  String closestBusStop;
  String routeDirection;
  String etaToNextBusStop;

  PublisherTelemetry(
      {required this.aid,
      this.busName = 'undefined',
      required this.bearing,
      required this.direction,
      required this.latitude,
      required this.longitude,
      required this.speed,
      required this.departureTime,
      required this.showDepartureTime,
      required this.closestBusStop,
      this.routeDirection = 'forward',
      required this.etaToNextBusStop});
}
