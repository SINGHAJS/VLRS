import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          showFailMessage,
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
              BuildContext context, String message)
          showSuccessMessage) {
    String name = nameController.text;
    String email = emailController.text;
    String feedback = feedbackController.text;

    if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
      showFailMessage(context, 'Please fill in all fields.');
      return;
    }

    if (!isEmailValid(email)) {
      showFailMessage(context, 'Please enter a valid email address.');
      return;
    }

    sendFeedbackToGmail(
        context, showSuccessMessage, showFailMessage, name, email, feedback);
    // showSuccessMessage(context, 'Feedback submitted successfully!');
    nameController.text = '';
    emailController.text = '';
    feedbackController.text = '';
  }

  Future<void> sendFeedbackToGmail(
      BuildContext context,
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
              BuildContext context, String message)
          showSuccessMessage,
      ScaffoldFeatureController<SnackBar, SnackBarClosedReason> Function(
              BuildContext context, String message)
          showFailMessage,
      String fromName,
      String fromEmail,
      String feedback) async {
    const serviceId = 'service_7w78hsw';
    const templateId = 'template_zb79dbi';
    const publicKey = '9syYeVFfs2vAMI9ji';
    const accessToken = '-pkLl6eyk97HVJ8QfAf6i';

    final sendEmailAPIEndPointUrl =
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        sendEmailAPIEndPointUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'accessToken': accessToken,
          'template_params': {
            'from_name': fromName,
            'from_email': fromEmail,
            'user_feedback': feedback,
          },
        }),
      );

      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        showSuccessMessage(context, 'Feedback submitted successfully!');
        print('Email sent successfully!');
      } else {
        showFailMessage(
            // ignore: use_build_context_synchronously
            context,
            'Failed to send email. Please try again later.');
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('An error occurred while sending email: $e');
    }
  }
}
