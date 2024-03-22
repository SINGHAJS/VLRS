class BusStop {
  final String name;
  final double latitude;
  final double longitude;
  double distanceToNextStop;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceToNextStop,
  });
}
