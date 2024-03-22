import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:vlrs/ui/splash_ui.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI
    SplashUI _splashUI = SplashUI();

    return Scaffold(
      body: Center(
        child: Container(
          decoration: const BoxDecoration(
            gradient: AppColours.BACKGROUND_PRIMARY_GRADIENT,
          ),
          width: double.infinity, // Take up full width
          height: double.infinity, // Take up full height
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: <Widget>[
              // Load application icon image from assets.
              _splashUI.showSplashScreenIcon(),
              _splashUI.showSplashScreenHeadings(),
              _splashUI.showContinueButton(context),
            ],
          ),
        ),
      ),
    );
  }
}
