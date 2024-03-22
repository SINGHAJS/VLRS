import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/services/geolocation_service.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/services/websocket_service.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/ui/map_route_ui.dart';
import 'package:vlrs/ui/map_ui.dart';
import 'package:vlrs/ui/loading_ui.dart';
import 'package:vlrs/ui/navigation_ui.dart';
import 'package:vlrs/utils/json_utils.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Logger
  final Logger logger = Logger();

  // Flags
  bool _isUserLocationAttained = false;
  bool _isRouteDataReceived = false;

  // Geolocation
  final GeolocationService _geolocationService = GeolocationService();
  late LatLng _userLatLng;

  // Map
  final JsonUtils _jsonUtils = JsonUtils();
  late List<LatLng> _mapRouteToData;
  late List<LatLng> _mapRouteFromData;
  late List<BusStop> _mapBusStopData;
  late List<BusStop> _forwardBusStopData;
  late List<BusStop> _backwardBusStopData;

  // WebSocket
  final WebSocketService _webSocketService = WebSocketService();

  // Models
  late PublisherTelemetry _publisherTelemetry;

  // Paths
  final String _routeCoordinatesToPath =
      'assets/coordinates/RouteCoordinatesTo.json';
  final String _routeCoordinatesFromPath =
      'assets/coordinates/RouteCoordinatesFrom.json';
  final String _busStopCoordinatesFile =
      'assets/coordinates/BusStopCoordinates.json';
  final String _busStopForwardCoordinatesFile =
      'assets/coordinates/ForwardBusStopCoordinates.json';
  final String _busStopBackwardCoordinatesFile =
      'assets/coordinates/BackwardBusStopCoordinates.json';

  // UI
  final MapUI _mapUI = MapUI();
  final LoadingUI _loadingUI = LoadingUI();
  final NavigationUI _navigationUI = NavigationUI();
  final MapRouteUI _mapRouteUI = MapRouteUI();

  // Lists
  final List<PublisherTelemetry> _telemetryDevices = [];

  // Controllers
  final MapRouteController _mapRouteController = MapRouteController();

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _webSocketService.validateToken();
    _getRoutesData();
  }

  @override
  void dispose() {
    _webSocketService.disposeWebSocketConnection;
    super.dispose();
  }

  ///
  /// Reads the coordinates file of the routes, initializes it, and updates the
  /// [_isRouteDataReceived] flag.
  ///
  Future<void> _getRoutesData() async {
    _mapRouteToData =
        await _jsonUtils.readLatLngFromJson(_routeCoordinatesToPath);
    _mapRouteFromData =
        await _jsonUtils.readLatLngFromJson(_routeCoordinatesFromPath);
    _mapBusStopData =
        await _jsonUtils.readBusStopDataFromJson(_busStopCoordinatesFile);

    _forwardBusStopData = await _jsonUtils
        .readBusStopDataFromJson(_busStopForwardCoordinatesFile);
    _backwardBusStopData = await _jsonUtils
        .readBusStopDataFromJson(_busStopBackwardCoordinatesFile);

    setState(() {
      _isRouteDataReceived = true;
    });
  }

  ///
  /// Gets the current user location and updates the [_isUserLocationAttained]
  /// flag.
  ///
  Future<void> _getUserLocation() async {
    _userLatLng = await _geolocationService.getCurrentUserLocation();
    setState(() {
      _isUserLocationAttained = true;
    });
  }

  ///
  /// This function takes the data snapshot and creates/updates a
  /// [PublisherTelemetry] object.
  ///
  /// [dataSnapshot] - String value of the snapshot data
  ///
  void updatePublisherTelemetryModel(String dataSnapshot) {
    final json = jsonDecode(dataSnapshot);
    final data = json['data'];
    String busName = data["bus"][0][1];
    double latitude = double.parse(data["latitude"][0][1]);
    double longitude = double.parse(data["longitude"][0][1]);
    double bearing = double.parse(data["bearing"][0][1]);
    double speed = double.parse(data["speed"][0][1]);
    String direction = data["direction"][0][1];
    String departureTime = data['departureTime'][0][1];
    String showDepartureTime = data['showDepartureTime'][0][1];
    String routeDirection = data['routeDirection'][0][1];

    // logger.i(data);

    final existingBusIndex =
        _telemetryDevices.indexWhere((device) => device.busName == busName);

    if (existingBusIndex != -1) {
      // Bus object exists, update existing data.
      _telemetryDevices[existingBusIndex].latitude = latitude;
      _telemetryDevices[existingBusIndex].longitude = longitude;
      _telemetryDevices[existingBusIndex].bearing = bearing;
      _telemetryDevices[existingBusIndex].speed = speed;
      _telemetryDevices[existingBusIndex].direction = direction;
      _telemetryDevices[existingBusIndex].departureTime = departureTime;
      _telemetryDevices[existingBusIndex].showDepartureTime = showDepartureTime;
      _telemetryDevices[existingBusIndex].closestBusStop =
          _mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
              _telemetryDevices[existingBusIndex],
              _mapBusStopData,
              _forwardBusStopData,
              _backwardBusStopData);
      _telemetryDevices[existingBusIndex].routeDirection = routeDirection;

      // _mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
      //     _telemetryDevices[existingBusIndex], _mapBusStopData);

      return;
    }

    // Bus object does not exist, create a new instance of the bus.
    // late BusStop closestBusStopToPublisherDevice =
    //     _mapBusStopData.firstWhere((element) => element.name == 'S/E');

    _publisherTelemetry = PublisherTelemetry(
      busName: busName,
      bearing: bearing,
      direction: direction,
      latitude: latitude,
      longitude: longitude,
      speed: speed,
      departureTime: departureTime,
      showDepartureTime: showDepartureTime,
      routeDirection: routeDirection,
    );

    _publisherTelemetry.closestBusStop =
        _mapRouteController.assignAndCalculateClosestBusStopToPublisherDevice(
            _publisherTelemetry,
            _mapBusStopData,
            _forwardBusStopData,
            _backwardBusStopData);

    // _publisherTelemetry.closestBusStop ??=
    //     _mapBusStopData.firstWhere((element) => element.name == 'S/E');

    _telemetryDevices.add(_publisherTelemetry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _webSocketService.telemetryStream().stream,
        builder: (context, snapshot) {
          if (!_mapUI.isMapWidgetReady(snapshot, _isUserLocationAttained)) {
            return _loadingUI.displayMapLoadingAnimation();
          } else {
            updatePublisherTelemetryModel(snapshot.data);
            return Stack(children: <Widget>[
              FlutterMap(
                options: MapOptions(
                  // center: _userLatLng,
                  center: const LatLng(-36.785334, 175.023230),
                  zoom: 17, // Default Zoom
                  maxZoom: 17, // Max Zoom
                  minZoom: 14, // Min Zoom
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vlrs.app',
                  ),
                  // MarkerLayer(
                  //   markers: [
                  // _mapUI.showUserMarkerOnMapUI(_userLatLng),
                  //   ],
                  // ),
                  _mapUI.showMultiplePublisherDeviceMarkerOnMap(
                      _telemetryDevices),
                  _mapUI.showUserCircleLayerOnMapUI(_userLatLng),
                  _mapRouteUI.drawVehicleRoute(_mapRouteToData, Colors.blue),
                  _mapRouteUI.drawVehicleRoute(_mapRouteFromData, Colors.blue),
                  _mapRouteUI.displayBusStopOnMap(
                      _mapBusStopData, _telemetryDevices),
                ],
              ),
              // Note: Use code below to show/use the navigation bar.
              // _navigationUI.showNavigationBar(context),
            ]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        backgroundColor: Colors.black,
        onPressed: () => {
          setState(() {
            _getUserLocation();
          })
        },
        child: const Icon(Icons.location_searching),
      ),
    );
  }
}
