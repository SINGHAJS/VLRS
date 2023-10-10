import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vlrs/screens/map_screen.dart';
import 'package:vlrs/screens/splash_screen.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
        path: '/map',
        name: 'Map',
        builder: (BuildContext context, GoRouterState state) {
          return const MapScreen();
        }),
    GoRoute(
        path: '/',
        name: 'Splash Screen',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        })
  ],
);
