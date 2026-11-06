import 'package:flutter/material.dart';

class AppTheme {

  static const Color pinkSoft = Color(0xFFFFB7B2);
  static const Color pinkAccent = Color(0xFFFF6B8B);
  static const Color yellowCream = Color(0xFFFFE194);
  static const Color mintGreen = Color(0xFFA8E6CF);
  static const Color purplePastel = Color(0xFFDCB0FF);
  static const Color bgCream = Color(0xFFFFF9F5);
  static const Color textDark = Color(0xFF4A3E3D);

  static ThemeData get theme {
    return ThemeData(
      scaffoldBackgroundColor: bgCream,
      fontFamily: 'Sans-Serif', 
      colorScheme: ColorScheme.fromSeed(
        seedColor: pinkAccent,
        primary: pinkAccent,
        secondary: mintGreen,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pinkAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: pinkSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}