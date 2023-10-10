import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vlrs/screens/map_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/map',
        name: 'Map',
        builder: (BuildContext context, GoRouterState state) {
          return const MapScreen();
        })
  ],
);
