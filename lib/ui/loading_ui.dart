import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingUI {
  final String _mapLoadingAnimationPath =
      'assets/animations/animation_lmpkib5u.json';

  ///
  /// This function returns a map loading animation to display when
  /// loading necessary data.
  ///
  /// Return: Center, lottie asset
  ///
  Widget displayMapLoadingAnimation() {
    return Center(child: Lottie.asset(_mapLoadingAnimationPath));
  }
}
