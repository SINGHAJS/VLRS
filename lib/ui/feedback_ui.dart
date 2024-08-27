import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';

class MessageSetupUI {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();

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
      'Have Something to say? Submit your feedback!',
      style: TextStyle(
          color: AppColours.ACCENT_COLOUR,
          fontSize: 20,
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

  Widget showFeedbackTextField() {
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
            controller: feedbackController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Feedback',
            ),
            maxLines: 10, // This allows the TextField to expand vertically
            keyboardType: TextInputType.multiline, // Allows multiline input
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
  Widget showSubmitFeedbackButton(void Function() onClickHandler) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onClickHandler,
        child: Container(
          height: 50,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColours.BACKGROUND_PRIMARY_COLOUR,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'Submit Feedback',
              style: TextStyle(
                color: AppColours.TEXT_SECONDARY_COLOR,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showInvalidInputMessage(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
      showSuccessInputMessage(BuildContext context, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
