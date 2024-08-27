import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:vlrs/controllers/feedback_input_controller.dart';
import 'package:vlrs/ui/feedback_ui.dart';
import 'package:vlrs/ui/navigation_ui.dart';
import 'package:vlrs/controllers/feedback_input_controller.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  final NavigationUI navigationUI = NavigationUI();
  final MessageSetupUI feedbackUI = MessageSetupUI();
  // final FeedbackInputValidator validator = FeedbackInputValidator();
  final FeedbackInputController feedbackInputController =
      FeedbackInputController();

  // void onSubmitFeedbackHandler() {
  //   String name = feedbackUI.nameController.text;
  //   String email = feedbackUI.emailController.text;
  //   String feedback = feedbackUI.feedbackController.text;

  //   if (name.isEmpty || email.isEmpty || feedback.isEmpty) {
  //     feedbackUI.showInvalidInputMessage(context, 'Please fill in all fields.');
  //     return;
  //   }

  //   if (!validator.isEmailValid(email)) {
  //     feedbackUI.showInvalidInputMessage(
  //         context, 'Please enter a valid email address.');
  //     return;
  //   }

  //   feedbackUI.showSuccessInputMessage(
  //       context, 'Feedback submitted successfully!');
  //   feedbackUI.nameController.text = '';
  //   feedbackUI.emailController.text = '';
  //   feedbackUI.feedbackController.text = '';
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColours.BACKGROUND_SECONDARY_COLOUR,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              feedbackUI.showMessageSetupIcon(),
              const SizedBox(height: 10),
              feedbackUI.showMessageSetupHeading(),
              const SizedBox(height: 50),
              feedbackUI.showUsernameTextField(),
              feedbackUI.showEmailTextField(),
              feedbackUI.showFeedbackTextField(),
              const SizedBox(height: 10),
              feedbackUI.showSubmitFeedbackButton(
                () => feedbackInputController.onSubmitFeedbackHandler(
                  context,
                  feedbackUI.nameController,
                  feedbackUI.emailController,
                  feedbackUI.feedbackController,
                  feedbackUI.showInvalidInputMessage,
                  feedbackUI.showSuccessInputMessage,
                ),
              ),
            ],
          ),
          navigationUI.showNavigationBar(context),
        ],
      ),
    );
  }
}
