class PublisherTelemetry {
  final double bearing;
  final String direction;
  final double latitude;
  final double longitude;
  final double speed;
  final String busName;

  PublisherTelemetry({
    this.busName = 'Bus X',
    required this.bearing,
    required this.direction,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });
}
