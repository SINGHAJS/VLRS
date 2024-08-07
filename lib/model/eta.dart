class ETA {
  String aid;
  String busStopName;
  String busName;
  String? estimateArrivalTime;
  String? distanceInKms;
  String? departureTime;
  bool showDepartureTime;

  ETA({
    required this.aid,
    required this.busStopName,
    required this.busName,
    this.estimateArrivalTime,
    this.distanceInKms,
    this.departureTime,
    required this.showDepartureTime,
  });
}
