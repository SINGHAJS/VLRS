import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

  // WebSocket
  final WebSocketService _webSocketService = WebSocketService();

  // Models
  late PublisherTelemetry _publisherTelemetry;

  // Paths
  final String _routeCoordinatesToPath =
      'assets/coordinates/RouteCoordinatesTo.json';
  final String _routeCoordinatesFromPath =
      'assets/coordinates/RouteCoordinatesFrom.json';

  // UI
  final MapUI _mapUI = MapUI();
  final LoadingUI _loadingUI = LoadingUI();
  final NavigationUI _navigationUI = NavigationUI();
  final MapRouteUI _mapRouteUI = MapRouteUI();

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
    _publisherTelemetry = PublisherTelemetry(
        bearing: double.parse(data["bearing"][0][1]),
        direction: data["direction"][0][1],
        latitude: double.parse(data["latitude"][0][1]),
        longitude: double.parse(data["longitude"][0][1]),
        speed: double.parse(data["speed"][0][1]));
  }

  @override
  Widget build(BuildContext context) {
    // print(_mapRouteToData);
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
                  // center: LatLng(_publisherTelemetry.latitude,
                  //     _publisherTelemetry.longitude),
                  // center: _userLatLng,
                  center: const LatLng(-36.785334, 175.023230),
                  zoom: 17, // Default Zoom
                  maxZoom: 17, // Max Zoom
                  minZoom: 14, // Min Zoom
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.vlrs.app',
                  ),
                  MarkerLayer(
                    markers: [
                      _mapUI.showUserMarkerOnMapUI(_userLatLng),
                      _mapUI.showPublisherDeviceMarkerOnMap(
                          LatLng(_publisherTelemetry.latitude,
                              _publisherTelemetry.longitude),
                          _publisherTelemetry.bearing)
                    ],
                  ),
                  _mapUI.showUserCircleLayerOnMapUI(_userLatLng),
                  _mapRouteUI.drawVehicleRoute(_mapRouteToData, Colors.blue),
                  _mapRouteUI.drawVehicleRoute(_mapRouteFromData, Colors.blue),
                ],
              ),
              // _navigationUI.showNavigationBar(context),
              // _mapRouteUI.drawVehicleRoute(),
            ]);
          }
        },
      ),
    );
  }
}
