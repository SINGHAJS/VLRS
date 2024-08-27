import 'package:flutter/material.dart';

class FeedbackInputController {
  bool isEmailValid(String email) {
    // Regular expression pattern for validating an email address
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-]+$",
    );

    return emailRegex.hasMatch(email);
  }

  void onSubmitFeedbackHandler(
      BuildContext context,
      TextEditingController nameController,
      TextEditingController emailController,
      TextEditingController feedbackController,
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
              BuildContext context, String message)
          showInvalidInputMessage,
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
              BuildContext context, String message)
          showSuccessInputMessage) {
    String name = nameController.text;
    String email = emailController.text;
    String feedback = feedbackController.text;

    if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
      showInvalidInputMessage(context, 'Please fill in all fields.');
      return;
    }

    if (!isEmailValid(email)) {
      showInvalidInputMessage(context, 'Please enter a valid email address.');
      return;
    }

    showSuccessInputMessage(context, 'Feedback submitted successfully!');
    nameController.text = '';
    emailController.text = '';
    feedbackController.text = '';
  }
}
