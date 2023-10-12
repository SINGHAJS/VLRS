import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationController {
  void onMapClickHandler(BuildContext context) {
    GoRouter.of(context).go('/map');
  }

  void onMessageClickHandler(BuildContext context) {
    GoRouter.of(context).go('/message');
  }

  void onSettingsClickHandler(BuildContext context) {
    GoRouter.of(context).go('/settings');
  }
}
