import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashController {
  ///
  /// On map button click, navigate to the map screen.
  ///
  void onContinueClickHandler(BuildContext context) {
    GoRouter.of(context).go('/map');
  }
}
