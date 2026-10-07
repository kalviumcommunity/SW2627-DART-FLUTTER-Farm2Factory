import 'package:flutter/material.dart';

/// App theme and color tokens matching the Farm2Factory brand identity.
class AppTheme {
  // Brand Colors
  static const Color brandGreen = Color(0xFF1F8A4C); // Rich dairy green
  static const Color brandGreenLight = Color(0xFF38B268); // Gradient green
  static const Color brandGreenDark = Color(0xFF135A31); // Dark forest green
  static const Color brandTeal = Color(0xFF1E3E4D); // Factory blue / teal
  static const Color brandOrange = Color(0xFFFF8C00); // Accent orange for payout/save
  static const Color brandOrangeEnd = Color(0xFFFF5722); // Gradient orange end
  
  // Pastel Card Backgrounds from Reference Design
  static const Color cardMint = Color(0xFFEBF7EE);
  static const Color cardSky = Color(0xFFE4F4FD);
  static const Color cardLavender = Color(0xFFF2EAF9);
  static const Color cardPeach = Color(0xFFFEF3E4);

  // Background & Surface
  static const Color scaffoldBg = Color(0xFFF9FAF9);
  static const Color cardSurface = Colors.white;

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF32A758), Color(0xFF19733C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFFFFA02E), Color(0xFFFF5E14)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandGreen,
      primary: brandGreen,
      secondary: brandTeal,
      surface: cardSurface,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF1E293B),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E293B),
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withOpacity(0.04)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandGreen, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
    ),
  );
}

