import 'package:flutter/material.dart';
import 'package:vlrs/controllers/navigation/navigation_controller.dart';
import 'package:vlrs/constants/app_colours.dart';

class NavigationUI {
  final NavigationController _navigationController = NavigationController();

  Widget showNavigationBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 60,
        width: 250,
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: AppColours.BACKGROUND_PRIMARY_COLOUR,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              color: AppColours.TEXT_PRIMARY_COLOR,
              onPressed: () => _navigationController.onMapClickHandler(context),
            ),
            IconButton(
              icon: const Icon(Icons.chat),
              color: AppColours.TEXT_PRIMARY_COLOR,
              onPressed: () =>
                  _navigationController.onMessageClickHandler(context),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              color: AppColours.TEXT_PRIMARY_COLOR,
              onPressed: () =>
                  _navigationController.onSettingsClickHandler(context),
            ),
          ],
        ),
      ),
    );
  }
}
