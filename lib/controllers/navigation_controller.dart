import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationController {
  ///
  /// On map button click, navigates to the map screen.
  ///
  void onMapClickHandler(BuildContext context) {
    GoRouter.of(context).go('/map');
  }

  ///
  /// On message button click, navigates to the message setup screen.
  ///
  void onMessageClickHandler(BuildContext context) {
    GoRouter.of(context).go('/message-setup');
  }

  ///
  /// On settings button click, navigates to the settings screen.
  ///
  void onSettingsClickHandler(BuildContext context) {
    GoRouter.of(context).go('/settings');
  }
}
