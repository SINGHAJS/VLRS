import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MessageController {
  void onStartChatClickHandler(
      BuildContext context, String name, String email) {
    GoRouter.of(context).go('/message');
  }
}
