class BusStop {
  final String name;
  final double latitude;
  final double longitude;
  final num distanceToNextStop;

  BusStop({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceToNextStop,
  });
}
