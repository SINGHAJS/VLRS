import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';

class MessageSetupUI {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  ///
  /// This function shows a customized message icon.
  ///
  /// Return: Widget, Container with Icon.
  ///
  Widget showMessageSetupIcon() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColours.BACKGROUND_PRIMARY_GRADIENT,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.chat,
        color: AppColours.TEXT_SECONDARY_COLOR,
        size: 80.0,
      ),
    );
  }

  ///
  /// This funciton shows the heading of the  message
  /// setup screen.
  ///
  /// Return: Widget, Text.
  ///
  Widget showMessageSetupHeading() {
    return const Text(
      'Chat with us!',
      style: TextStyle(
          color: AppColours.ACCENT_COLOUR,
          fontSize: 25,
          fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  ///
  /// This funciton shows a textfield to for
  /// user email input.
  ///
  /// Return: Widget, Padding with TextField.
  ///
  Widget showEmailTextField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: emailController,
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: 'Email'),
          ),
        ),
      ),
    );
  }

  ///
  /// This funciton shows a textfield to for
  /// user name input.
  ///
  /// Return: Widget, Padding with TextField.
  ///
  Widget showUsernameTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(
                border: InputBorder.none, hintText: 'Name'),
          ),
        ),
      ),
    );
  }

  ///
  /// This function shows the button with 'START CHAT' to allow users
  /// to start a converstaion.
  ///
  /// Return: Widget, Padding with Container
  Widget showStartChatButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: () => {},
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'START CHAT',
              style: TextStyle(
                  color: AppColours.TEXT_SECONDARY_COLOR,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}
