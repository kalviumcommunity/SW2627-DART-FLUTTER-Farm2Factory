import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// App theme and color tokens matching the Farm2Factory brand identity.
/// Provides dynamic responsive color resolution for Light and Dark modes.
class AppTheme {
  // Brand Colors - Executive Supply Chain Palette
  static const Color brandGreen = Color(0xFF0F5132); // Executive Forest Emerald
  static const Color brandGreenLight = Color(0xFF10B981); // Modern Emerald Accent
  static const Color brandGreenDark = Color(0xFF0A3E26); // Deep Nordic Pine
  static const Color brandTeal = Color(0xFF0F172A); // Obsidian Slate / Deep Navy
  static const Color brandOrange = Color(0xFFD97706); // Refined Amber for CTAs
  static const Color brandOrangeEnd = Color(0xFFB45309); // Deep Amber gradient end

  /// Indicates if dark mode is currently active
  static bool get isDark => ThemeController.instance.isDark;

  // Enterprise Canvas & Clean Surfaces
  static Color get scaffoldBg => isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
  static Color get creamSurface => isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
  static Color get creamLight => isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get creamBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get cardSurface => isDark ? const Color(0xFF1E293B) : Colors.white;
  static Color get surfaceHighlight => isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color get subtleBorder => isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  // High-Contrast Enterprise Typography
  static Color get textPrimary => isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get textMuted => isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // Micro-Tints for Cards & Badges
  static Color get cardMint => isDark ? const Color(0xFF064E3B).withOpacity(0.45) : const Color(0xFFF0FDF4);
  static Color get cardSky => isDark ? const Color(0xFF0C4A6E).withOpacity(0.45) : const Color(0xFFF0F9FF);
  static Color get cardLavender => isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  static Color get cardPeach => isDark ? const Color(0xFF78350F).withOpacity(0.45) : const Color(0xFFFFFBEB);

  // Dynamic Theme Accents & Badges
  static Color get accentGreen => isDark ? const Color(0xFF10B981) : const Color(0xFF0F5132);
  static Color get accentGreenLight => isDark ? const Color(0xFF34D399) : const Color(0xFF166534);

  // Status Badges Colors (Luminous in Dark, Crisp in Light)
  static Color get badgeMintBg => isDark ? const Color(0xFF064E3B).withOpacity(0.5) : const Color(0xFFDCFCE7);
  static Color get badgeMintText => isDark ? const Color(0xFF4ADE80) : const Color(0xFF166534);
  static Color get badgeMintBorder => isDark ? const Color(0xFF10B981).withOpacity(0.35) : const Color(0xFF86EFAC);

  static Color get badgeSkyBg => isDark ? const Color(0xFF0C4A6E).withOpacity(0.5) : const Color(0xFFE0F2FE);
  static Color get badgeSkyText => isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1);
  static Color get badgeSkyBorder => isDark ? const Color(0xFF0284C7).withOpacity(0.35) : const Color(0xFF7DD3FC);

  static Color get badgeAmberBg => isDark ? const Color(0xFF78350F).withOpacity(0.5) : const Color(0xFFFEF3C7);
  static Color get badgeAmberText => isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309);
  static Color get badgeAmberBorder => isDark ? const Color(0xFFD97706).withOpacity(0.35) : const Color(0xFFFCD34D);

  static Color get badgeRoseBg => isDark ? const Color(0xFF7F1D1D).withOpacity(0.5) : const Color(0xFFFEE2E2);
  static Color get badgeRoseText => isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B);
  static Color get badgeRoseBorder => isDark ? const Color(0xFFDC2626).withOpacity(0.35) : const Color(0xFFFCA5A5);

  static Color get badgeNeutralBg => isDark ? const Color(0xFF334155).withOpacity(0.5) : const Color(0xFFF1F5F9);
  static Color get badgeNeutralText => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  static Color get badgeNeutralBorder => isDark ? const Color(0xFF475569).withOpacity(0.35) : const Color(0xFFCBD5E1);

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

  /// Light Theme Configuration
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandGreen,
      brightness: Brightness.light,
      primary: brandGreen,
      secondary: brandTeal,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
      outline: const Color(0xFFE2E8F0),
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFF8FAFC),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF0F172A),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF0F172A),
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFF8FAFC),
      indicatorColor: brandGreen.withOpacity(0.15),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: brandGreen, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Color(0xFF64748B), fontSize: 12);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
  );

  /// Dark Theme Configuration - Midnight Obsidian Palette
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B1120),
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandGreen,
      brightness: Brightness.dark,
      primary: brandGreenLight,
      onPrimary: Colors.white,
      secondary: const Color(0xFF38BDF8),
      surface: const Color(0xFF1E293B),
      onSurface: const Color(0xFFF8FAFC),
      surfaceTint: Colors.transparent,
      outline: const Color(0xFF334155),
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0B1120),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFFF8FAFC),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFFF8FAFC)),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandGreenLight, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
      labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0F172A),
      indicatorColor: const Color(0xFF10B981).withOpacity(0.2),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Color(0xFF34D399));
        }
        return const IconThemeData(color: Color(0xFF94A3B8));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Color(0xFF94A3B8), fontSize: 12);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF334155)),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFF8FAFC),
      ),
      contentTextStyle: const TextStyle(
        fontSize: 13.5,
        color: Color(0xFFCBD5E1),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1E293B),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
  );
}
