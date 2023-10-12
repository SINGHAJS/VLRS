import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vlrs/constants/app_colours.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void onContinueClickHandler() {
      context.go('/map');
    }

    return Scaffold(
      body: Center(
        child: Container(
          color: AppColours.BACKGROUND_PRIMARY_COLOUR,
          width: double.infinity, // Take up full width
          height: double.infinity, // Take up full height
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.spaceEvenly, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: <Widget>[
              // Load application icon image from assets.
              Image.asset(
                'assets/images/splash_screen/earth_pin_location.png',
                width: 200,
                height: 200,
              ),
              const Column(
                children: [
                  Text(
                    'WELCOME TO VLRS!',
                    style: TextStyle(
                      color: AppColours.ACCENT_COLOUR,
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
              ),
              SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: onContinueClickHandler,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.ACCENT_COLOUR,
                  ),
                  child: const Text(
                    'CONTINUE',
                    style: TextStyle(
                      color: AppColours.TEXT_PRIMARY_COLOR,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
