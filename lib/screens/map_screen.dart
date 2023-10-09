import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:vlrs/services/geolocation_service.dart';

import '../config/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // instance of geolocation service
  final GeolocationService _geolocationService = GeolocationService();

  // variable to store user location
  late LatLng _userLatLng;

  // map controller to move map center
  late MapController? _mapController;

  // instance of hive box to store jwt token and expired token
  final box = Hive.box('vlrs');

  // variable to store jwt token
  String? jwtToken;

  // variable stream to listen datetime now
  late Stream<DateTime> stream;

  // get telemetry data from thingsboard server
  WebSocketChannel _telemetryStream() {
    var uri = Uri.parse(
        "ws://43.226.218.94:8080/api/ws/plugins/telemetry?token=$jwtToken");
    final telemetryStream = WebSocketChannel.connect(uri);
    var object = {
      "tsSubCmds": [
        {
          "entityType": "DEVICE",
          "entityId": busAId,
          "scope": "LATEST_TELEMETRY",
          "cmdId": 10
        }
      ],
      "historyCmds": [],
      "attrSubCmds": []
    };
    var data = jsonEncode(object); // convert object to json
    telemetryStream.sink.add(data); // send data to thingsboard server
    return telemetryStream; // return telemetry stream to use in stream builder
  }

  // check if jwt token is null or expired
  void checkToken() async {
    // get jwt token from hive box
    jwtToken = box.get('token');

    // if jwt token is null, send request to get new jwt token
    if (jwtToken == null) {
      // get new jwt token
      String? token = await fetchJwtToken();
      if (token != null) {
        // if success, store jwt token and expired token to hive box
        box.put('token', token);
        jwtToken = token;
        var expiredAt = DateTime.now().add(const Duration(minutes: 90));
        var stringExpireAt = expiredAt.toIso8601String();
        box.put('expiredToken', stringExpireAt);
      }
    } else {
      // if jwt token is not null, check if jwt token is expired
      var expiredAt = box.get('expiredToken');
      var expiredAtDateTime = DateTime.parse(expiredAt);
      var now = DateTime.now();

      if (now.isAfter(expiredAtDateTime)) {
        // if expired, send request to get new jwt token
        resendRequest();
      } else {
        // if not expired, check every minute if jwt token is expired
        stream = Stream<DateTime>.periodic(
          const Duration(minutes: 1),
          (count) => DateTime.now(),
        );
        stream.listen((event) {
          if (event.isAfter(expiredAtDateTime)) {
            resendRequest();

            // close stream
            stream.drain();
          }
        });
      }
    }
  }

  // resend request to get new jwt token if jwt token is expired or null
  resendRequest() async {
    var jwtToken = await fetchJwtToken();
    this.jwtToken = jwtToken;
    box.put('token', jwtToken);
    checkToken();
  }

  // send request to thingsboard server to get jwt token
  Future<String?> fetchJwtToken() async {
    final dio = Dio();
    const url = 'http://43.226.218.94:8080/api/auth/login'; // thingsboard url

    final data = {
      // change this to your username and password of your thingsboard account
      'username': 'tenant@thingsboard.org',
      'password': 'tenant',
    };

    try {
      // send post request to thingsboard server to get jwt token
      // if success, return jwt token
      // if failed, return null
      final response = await dio.post(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['token'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // get user location
  Future<void> _getUserLocation() async {
    LatLng currentLatLng = await _geolocationService.getCurrentUserLocation();
    setState(() {
      _userLatLng = currentLatLng;
    });
  }

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getUserLocation();
    checkToken();
  }

  @override
  void dispose() {
    // dispose map controller and stream
    _mapController!.dispose();
    stream.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: _telemetryStream().stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasData == false) {
            return Center(
              child: lottie.Lottie.asset(
                  "assets/animations/animation_lmpkib5u.json"),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Error"),
            );
          }

          // get telemetry data from thingsboard server
          var json = jsonDecode(snapshot.data);
          var data = json['data'];
          var stringLat = data["latitude"][0][1];
          var stringLng = data["longitude"][0][1];

          // convert string to double
          var lat = double.parse(stringLat);
          var lng = double.parse(stringLng);

          // return flutter map widget to display map
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
                center: LatLng(lat, lng),
                zoom: 14,
                maxZoom: 18,
                minZoom: 14,
                onMapReady: () {
                  _mapController!.move(LatLng(lat, lng), 18);
                }),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.vlrs.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(lat, lng),
                    width: 80,
                    height: 80,
                    builder: (context) => const Icon(
                      Icons.my_location,
                      size: 35.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
