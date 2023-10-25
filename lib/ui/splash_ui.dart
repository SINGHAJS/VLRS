import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:vlrs/controllers/splash_controller.dart';

class SplashUI {
  // Controller
  SplashController _splashController = SplashController();

  ///
  /// This function shows the splash screen icon.
  ///
  /// Return: Widget, Image asset.
  Widget showSplashScreenIcon() {
    return Image.asset(
      'assets/images/splash_screen/earth_pin_location.png',
      width: 200,
      height: 200,
    );
  }

  ///
  /// This funciton shows the splash screen heading.
  ///
  /// Return: Widget, Text.
  ///
  Widget showSplashScreenHeadings() {
    return const Column(
      children: [
        Text(
          'WELCOME TO VLRS!',
          style: TextStyle(
            color: AppColours.TEXT_PRIMARY_COLOR,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'VEHICLE LOCATION REPORTING SYSTEM',
          style: TextStyle(
            color: AppColours.TEXT_PRIMARY_COLOR,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  ///
  /// This function takes the build context as the input
  /// parameter and shows the continue the button.
  ///
  /// Param: [context], used for on continue click handler.
  ///
  /// Return: Widget, SizedBox with ElevatedButton.
  ///
  Widget showContinueButton(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 40,
      child: ElevatedButton(
        onPressed: () => _splashController.onContinueClickHandler(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColours.BACKGROUND_PRIMARY_COLOUR,
        ),
        child: const Text(
          'CONTINUE',
          style: TextStyle(
            color: AppColours.TEXT_SECONDARY_COLOR,
          ),
        ),
      ),
    );
  }
}
