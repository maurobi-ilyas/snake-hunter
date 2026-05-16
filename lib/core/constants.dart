import 'package:flutter/material.dart';

/// X10THINK Visual Identity System — Premium Casual Mobile Game
class GameColors {
  // === BRAND COLORS ===
  static const Color primary    = Color(0xFF2ECC71); // Vibrant Emerald
  static const Color secondary  = Color(0xFF27AE60); // Deep Emerald
  static const Color accent     = Color(0xFFFFD32A); // Warm Gold
  static const Color danger     = Color(0xFFFF4757); // Alert Red

  // === SNAKE COLORS ===
  static const Color snakeHead  = Color(0xFF1ABC9C); // Teal-Green
  static const Color snakeBody  = Color(0xFF16A085); // Deep Teal
  static const Color snakeEye   = Color(0xFFFFFFFF); // White
  static const Color snakeGlow  = Color(0xFF48FAD9); // Neon Teal

  // === ENVIRONMENT ===
  static const Color groundLight  = Color(0xFF8BC34A); // Grass Light
  static const Color groundMid    = Color(0xFF7CB342); // Grass Mid
  static const Color groundDark   = Color(0xFF558B2F); // Grass Dark
  static const Color flowerRed    = Color(0xFFE53935); // Flower Red
  static const Color flowerYellow = Color(0xFFFFB300); // Flower Yellow
  static const Color flowerPink   = Color(0xFFE91E63); // Flower Pink
  static const Color flowerWhite  = Color(0xFFFFFFFF); // Flower White
  static const Color rockGray     = Color(0xFFB0BEC5); // Rock Gray
  static const Color rockDark     = Color(0xFF78909C); // Rock Shadow
  static const Color mushroomRed  = Color(0xFFD32F2F); // Mushroom Cap
  static const Color mushroomStem = Color(0xFFFFF9C4); // Mushroom Stem
  static const Color pathDirt     = Color(0xFFD7CCC8); // Dirt Path

  // === UI COLORS ===
  static const Color hudBg       = Color(0x99000000); // HUD dark bg
  static const Color hudBorder   = Color(0x33FFFFFF); // HUD border
  static const Color hudText     = Color(0xFFFFFFFF);
  static const Color hudSubtext  = Color(0xCCFFFFFF);
  static const Color comboGold   = Color(0xFFFFD32A);
  static const Color comboBg     = Color(0xCC7B1FA2); // Purple glow bg

  // === MENU COLORS ===
  static const Color menuGrad1   = Color(0xFF1B5E20); // Deep Forest
  static const Color menuGrad2   = Color(0xFF2E7D32); // Mid Forest
  static const Color menuGrad3   = Color(0xFF43A047); // Light Forest

  // Legacy compat
  static const Color background       = Color(0xFF1B5E20);
  static const Color pastelPink       = Color(0xFFFFCDD2);
  static const Color pastelBlue       = Color(0xFFBBDEFB);
  static const Color pastelGreen      = Color(0xFFC8E6C9);
  static const Color pastelYellow     = Color(0xFFFFF9C4);
  static const Color glassBackground  = Color(0x33FFFFFF);
}

class GameStyles {
  static const double borderRadius = 20.0;
  static const double spacing = 16.0;

  /// Premium floating glass panel
  static BoxDecoration get glassmorphism => BoxDecoration(
    color: const Color(0x22FFFFFF),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: const Color(0x44FFFFFF), width: 1.2),
    boxShadow: const [
      BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 4)),
    ],
  );

  /// Rich dark HUD panel with glow border
  static BoxDecoration get hudPanel => BoxDecoration(
    color: const Color(0xCC1B2E1A),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: const Color(0x662ECC71), width: 1.5),
    boxShadow: const [
      BoxShadow(color: Color(0x882ECC71), blurRadius: 10, spreadRadius: -2),
      BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3)),
    ],
  );

  /// Gold accent panel (combo)
  static BoxDecoration get comboPanel => BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFFD32A), Color(0xFFFF9100)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Color(0x88FFD32A), blurRadius: 12, spreadRadius: 0),
    ],
  );
}
