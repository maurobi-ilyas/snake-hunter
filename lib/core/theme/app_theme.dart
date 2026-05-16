import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bgDark = Color(0xFF050816);
  static const Color neonGreen = Color(0xFF00FF9D);
  static const Color neonGreenDim = Color(0xFF00C97B);
  static const Color darkGreen = Color(0xFF071A12);

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    textTheme: GoogleFonts.orbitronTextTheme(
      ThemeData.dark().textTheme,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      titleTextStyle: GoogleFonts.orbitron(
        color: neonGreen,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 3,
      ),
      iconTheme: const IconThemeData(color: neonGreen),
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonGreen,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.orbitron(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 2,
        ),
      ),
    ),
  );
}
