import 'package:flutter/material.dart';

/// One place for colours and shared styles.
/// The two brand colours are taken from the Farm2Factory logo.
class AppTheme {
  static const Color brandBlue = Color(0xFF2F5A6B); // factory blue
  static const Color brandGreen = Color(0xFF5E9A45); // farm green

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(seedColor: brandBlue).copyWith(secondary: brandGreen),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
