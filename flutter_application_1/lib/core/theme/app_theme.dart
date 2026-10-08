import 'package:flutter/material.dart';

/// App theme and color tokens matching the Farm2Factory brand identity.
class AppTheme {
  // Brand Colors
  static const Color brandGreen = Color(0xFF267332); // Rich dairy meadow green
  static const Color brandGreenLight = Color(0xFF38B268); // Gradient green
  static const Color brandGreenDark = Color(0xFF1B5E20); // Dark forest green
  static const Color brandTeal = Color(0xFF1E3E4D); // Factory blue / teal
  static const Color brandOrange = Color(0xFFE58B24); // Warm golden amber for Save Farmer CTA
  static const Color brandOrangeEnd = Color(0xFFC76F0E); // Deep amber gradient end
  
  // Warm Dairy Cream & Pastoral Theme
  static const Color scaffoldBg = Color(0xFFFAF6EE); // Warm rich dairy cream background
  static const Color creamSurface = Color(0xFFF5EEDB); // Warm cream accent surface
  static const Color creamLight = Color(0xFFFDFBF7); // Soft ivory white
  static const Color creamBorder = Color(0xFFEFE8DA); // Subtle warm cream border
  static const Color cardSurface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Pastel Card Backgrounds from Reference Design
  static const Color cardMint = Color(0xFFEBF7EE);
  static const Color cardSky = Color(0xFFE4F4FD);
  static const Color cardLavender = Color(0xFFF2EAF9);
  static const Color cardPeach = Color(0xFFFEF3E4);

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFE58B24), Color(0xFFC76F0E)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient orangeGradient = amberGradient;

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: scaffoldBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandGreen,
      primary: brandGreen,
      secondary: brandTeal,
      surface: cardSurface,
      background: scaffoldBg,
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBg,
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
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: creamBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: creamBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: creamBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: brandGreen, width: 1.5),
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 14),
    ),
  );
}

