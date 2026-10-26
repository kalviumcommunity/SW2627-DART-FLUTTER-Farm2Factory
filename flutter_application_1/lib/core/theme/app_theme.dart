import 'package:flutter/material.dart';

/// App theme and color tokens matching the Farm2Factory brand identity.
class AppTheme {
  // Brand Colors - Executive Supply Chain Palette
  static const Color brandGreen = Color(0xFF0F5132); // Executive Forest Emerald (was 0xFF267332)
  static const Color brandGreenLight = Color(0xFF10B981); // Modern Emerald Accent
  static const Color brandGreenDark = Color(0xFF0A3E26); // Deep Nordic Pine
  static const Color brandTeal = Color(0xFF0F172A); // Obsidian Slate / Deep Navy
  static const Color brandOrange = Color(0xFFD97706); // Refined Amber for CTAs
  static const Color brandOrangeEnd = Color(0xFFB45309); // Deep Amber gradient end
  
  // Enterprise Canvas & Clean Surfaces (Replaces yellowish cream with crisp Slate-50 / Slate-200)
  static const Color scaffoldBg = Color(0xFFF8FAFC); // Slate-50: Crisp, clean, modern enterprise canvas
  static const Color creamSurface = Color(0xFFF1F5F9); // Slate-100: Clean neutral surface
  static const Color creamLight = Colors.white; // Pure crisp white
  static const Color creamBorder = Color(0xFFE2E8F0); // Slate-200: Razor-sharp 1px neutral border
  static const Color cardSurface = Colors.white;

  // High-Contrast Enterprise Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900: High-contrast, sharp typography
  static const Color textSecondary = Color(0xFF475569); // Slate-600: Secondary text
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400: Muted labels

  // Calibrated Micro-Tints (Replaces cartoonish/vibe-coded candy pastel card fills)
  static const Color cardMint = Color(0xFFF0FDF4); // Subtle Emerald-50 tint
  static const Color cardSky = Color(0xFFF0F9FF); // Subtle Sky-50 tint
  static const Color cardLavender = Color(0xFFF8FAFC); // Neutral Slate-50 tint
  static const Color cardPeach = Color(0xFFFFFBEB); // Subtle Amber-50 tint

  // Gradients
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF0F5132), Color(0xFF0A3E26)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient amberGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFB45309)],
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
      surfaceTint: Colors.transparent, // Disable purple/pink M3 tint on surfaces
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: scaffoldBg,
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF0F172A),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: creamBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: creamBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: creamBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
    ),
  );
}

