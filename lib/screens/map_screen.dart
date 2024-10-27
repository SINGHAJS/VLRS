import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:vlrs/controllers/map_route_controller.dart';
import 'package:vlrs/model/bus_stop.dart';
import 'package:vlrs/services/geolocation_service.dart';
import 'package:logger/logger.dart';
import 'package:vlrs/services/websocket_service.dart';
import 'package:vlrs/model/publisher_telemetry.dart';
import 'package:vlrs/ui/bus_stop_ui.dart';
import 'package:vlrs/ui/map_route_ui.dart';
import 'package:vlrs/ui/map_ui.dart';
import 'package:vlrs/ui/loading_ui.dart';
import 'package:vlrs/ui/navigation_ui.dart';
import 'package:vlrs/utils/json_utils.dart';
import 'package:vlrs/providers/telemetry_devices_provider.dart';
import 'package:vlrs/providers/estimate_time_arrival_provider.dart';
import 'package:vlrs/providers/bus_stop_data_provider.dart';
import 'package:vlrs/model/bus_stop_data.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
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
  List<LatLng> _mapRouteToData = [];
  List<LatLng> _mapRouteFromData = [];
  List<BusStop> _mapBusStopData = [];
  // List<BusStopData> _mapBusStopDataFromStream = [];
  List<BusStop> _forwardBusStopData = [];
  List<BusStop> _backwardBusStopData = [];

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
  final BusStopUI _busStopUI = BusStopUI();

  // Lists
  // final List<PublisherTelemetry> _telemetryDevices = [];

  // Controllers
  // final MapRouteController _mapRouteController = MapRouteController();

  @override
  void initState() {
    super.initState();
    _webSocketService.validateToken();
    _getUserLocation();
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
    List<LatLng> mapRouteToData =
        await _jsonUtils.readLatLngFromJson(_routeCoordinatesToPath);
    List<LatLng> mapRouteFromData =
        await _jsonUtils.readLatLngFromJson(_routeCoordinatesFromPath);
    List<BusStop> mapBusStopData =
        await _jsonUtils.readBusStopDataFromJson(_busStopCoordinatesFile);
    List<BusStop> forwardBusStopData = await _jsonUtils
        .readBusStopDataFromJson(_busStopForwardCoordinatesFile);
    List<BusStop> backwardBusStopData = await _jsonUtils
        .readBusStopDataFromJson(_busStopBackwardCoordinatesFile);

    setState(() {
      _mapRouteToData = mapRouteToData;
      _mapRouteFromData = mapRouteFromData;
      _mapBusStopData = mapBusStopData;
      _forwardBusStopData = forwardBusStopData;
      _backwardBusStopData = backwardBusStopData;

      _isRouteDataReceived = true;
      logger.i("Route Data Ready");
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
      logger.i("Location Data Ready");
    });
  }

  @override
  Widget build(BuildContext context) {
    logger.d(ref.watch(telemetryDevicesProvider));
    return Scaffold(
      body: StreamBuilder(
        stream: _webSocketService.telemetryStream().stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return _loadingUI.displayMapLoadingAnimation();
          }

          if (!_mapUI.isMapWidgetReady(snapshot, _isUserLocationAttained) &&
              !_isRouteDataReceived) {
            return _loadingUI.displayMapLoadingAnimation();
          } else if (_mapUI.isMapWidgetReady(
                  snapshot, _isUserLocationAttained) &&
              _isRouteDataReceived) {
            ref
                .read(telemetryDevicesProvider.notifier)
                .addPublisherTelemetryDevice(snapshot.data);

            // ref
            //     .read(busStopDataProvider
            //         .notifier) // <-- Read bus stop data from the provider
            //     .addBusStopData(
            //         snapshot.data); // <-- Add bus stop data from WebSocket

            // _mapBusStopData = ref.watch(busStopDataProvider);

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
                      ref.watch(telemetryDevicesProvider)),
                  _mapUI.showUserCircleLayerOnMapUI(_userLatLng),
                  _mapRouteUI.drawVehicleRoute(_mapRouteToData, Colors.blue),
                  _mapRouteUI.drawVehicleRoute(_mapRouteFromData, Colors.blue),
                  _busStopUI.displayBusStopOnMap(
                      _mapBusStopData,
                      ref.watch(telemetryDevicesProvider),
                      _forwardBusStopData,
                      _backwardBusStopData,
                      ref.watch(estimateTimeArrivalProvider)),
                ],
              ),
              // Note: Use code below to show/use the navigation bar.
              _navigationUI.showNavigationBar(context),
            ]);
          } else {
            return _loadingUI.displayMapLoadingAnimation();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: FloatingActionButton(
          elevation: 10,
          backgroundColor: Colors.black,
          onPressed: () {
            setState(() {
              _getUserLocation();
            });
          },
          child: const Icon(
            Icons.location_searching,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
