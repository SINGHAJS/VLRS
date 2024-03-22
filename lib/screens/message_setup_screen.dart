import 'package:flutter/material.dart';
import 'package:vlrs/constants/app_colours.dart';
import 'package:vlrs/ui/message_setup_ui.dart';
import 'package:vlrs/ui/navigation_ui.dart';

class MessageSetupScreen extends StatelessWidget {
  const MessageSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI
    final NavigationUI _navigationUI = NavigationUI();
    final MessageSetupUI _messageSetupUI = MessageSetupUI();

    return Scaffold(
      backgroundColor: AppColours.BACKGROUND_SECONDARY_COLOUR,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _messageSetupUI.showMessageSetupIcon(),
              const SizedBox(height: 10),
              _messageSetupUI.showMessageSetupHeading(),
              const SizedBox(height: 50),
              _messageSetupUI.showEmailTextField(),
              _messageSetupUI.showUsernameTextField(),
              const SizedBox(height: 10),
              _messageSetupUI.showStartChatButton(),
            ],
          ),
          _navigationUI.showNavigationBar(context)
        ],
      ),
    );
  }
}
