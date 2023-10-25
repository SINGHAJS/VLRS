import 'package:flutter/material.dart';

class AppColours {
  static const Color BACKGROUND_PRIMARY_COLOUR = Color(0xFF000814);
  static const Color BACKGROUND_SECONDARY_COLOUR = Color(0xFFFFFFFF);
  static const Color TEXT_PRIMARY_COLOR = Color(0xFF000814);
  static const Color TEXT_SECONDARY_COLOR = Color(0xFFEDF2F4);
  static const Color ACCENT_COLOUR = Color(0xFF000814);

  static const LinearGradient BACKGROUND_PRIMARY_GRADIENT = LinearGradient(
    colors: [Color(0xFF87CEEB), Color(0xFF6A5ACD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
