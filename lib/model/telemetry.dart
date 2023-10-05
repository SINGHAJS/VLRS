class Telemetry {
  final double bearing;
  final String direction;
  final double latitude;
  final double longitude;
  final double speed;

  Telemetry({
    required this.bearing,
    required this.direction,
    required this.latitude,
    required this.longitude,
    required this.speed,
  });

  factory Telemetry.fromJson(Map<String, dynamic> json) {
    return Telemetry(
      bearing: json['bearing'],
      direction: json['direction'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      speed: json['speed'],
    );
  }
}
