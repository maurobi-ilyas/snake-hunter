import 'package:flutter/material.dart';

class GameColors {
  static const Color primary = Color(0xFF64B5F6); // Soft Blue
  static const Color secondary = Color(0xFF81C784); // Soft Green
  static const Color accent = Color(0xFFFFD54F); // Soft Yellow
  static const Color background = Color(0xFFF5F5F5);
  static const Color snakeHead = Color(0xFF4CAF50);
  static const Color snakeBody = Color(0xFF81C784);
  
  // Pastel palette
  static const Color pastelPink = Color(0xFFFFCDD2);
  static const Color pastelBlue = Color(0xFFBBDEFB);
  static const Color pastelGreen = Color(0xFFC8E6C9);
  static const Color pastelYellow = Color(0xFFFFF9C4);
  
  static const Color glassBackground = Colors.white24;
}

class GameStyles {
  static const double borderRadius = 20.0;
  static const double spacing = 16.0;
  
  static BoxDecoration glassmorphism = BoxDecoration(
    color: Colors.white.withOpacity(0.2),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
  );
}
