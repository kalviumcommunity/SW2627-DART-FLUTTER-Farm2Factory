import 'package:flutter/material.dart';

import 'theme_controller.dart';

/// App theme and color tokens matching the Farm2Factory brand identity.
/// Provides dynamic responsive color resolution for Light, Dark, and Warm Peach modes.
class AppTheme {
  // Brand Colors - Executive Supply Chain Palette
  static const Color brandGreen = Color(0xFF0F5132); // Executive Forest Emerald
  static const Color brandGreenLight = Color(0xFF10B981); // Modern Emerald Accent
  static const Color brandGreenDark = Color(0xFF0A3E26); // Deep Nordic Pine
  static const Color brandTeal = Color(0xFF0F172A); // Obsidian Slate / Deep Navy
  static const Color brandOrange = Color(0xFFD97706); // Refined Amber for CTAs
  static const Color brandOrangeEnd = Color(0xFFB45309); // Deep Amber gradient end

  // Brand Colors - Warm Harvest Peach Palette
  static const Color brandPeach = Color(0xFFFF8A65); // Warm Sunset Peach
  static const Color brandPeachLight = Color(0xFFFFCCBC); // Soft Luminous Peach
  static const Color brandPeachDark = Color(0xFFE64A19); // Terracotta Peach Accent
  static const Color brandPeachDeep = Color(0xFFBF360C); // Deep Roasted Peach

  /// Indicates if dark mode is currently active
  static bool get isDark => ThemeController.instance.isDark;

  /// Indicates if warm peach mode is currently active
  static bool get isPeach => ThemeController.instance.isPeach;

  // Enterprise Canvas & Clean Surfaces
  static Color get scaffoldBg {
    if (isPeach) return const Color(0xFFFFF7F2);
    return isDark ? const Color(0xFF0B1120) : const Color(0xFFFAF7F4);
  }

  static Color get creamSurface {
    if (isPeach) return const Color(0xFFFFEDE4);
    return isDark ? const Color(0xFF1E293B) : const Color(0xFFF7EFE9);
  }

  static Color get creamLight {
    if (isPeach) return const Color(0xFFFFF9F5);
    return isDark ? const Color(0xFF1E293B) : Colors.white;
  }

  static Color get creamBorder {
    if (isPeach) return const Color(0xFFFFD5C2);
    return isDark ? const Color(0xFF334155) : const Color(0xFFEFE4DC);
  }

  static Color get cardSurface {
    if (isPeach) return Colors.white;
    return isDark ? const Color(0xFF1E293B) : Colors.white;
  }

  static Color get surfaceHighlight {
    if (isPeach) return const Color(0xFFFFE5D6);
    return isDark ? const Color(0xFF334155) : const Color(0xFFF5ECE4);
  }

  static Color get subtleBorder {
    if (isPeach) return const Color(0xFFFFD5C2);
    return isDark ? const Color(0xFF334155) : const Color(0xFFEFE4DC);
  }

  // High-Contrast Enterprise Typography
  static Color get textPrimary {
    if (isPeach) return const Color(0xFF3E1D13); // Deep roast terracotta
    return isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  }

  static Color get textSecondary {
    if (isPeach) return const Color(0xFF7A4B3A);
    return isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  }

  static Color get textMuted {
    if (isPeach) return const Color(0xFFA87565);
    return isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  }

  // Micro-Tints for Cards & Badges
  static Color get cardMint {
    if (isPeach) return const Color(0xFFFFF0EA);
    return isDark ? const Color(0xFF064E3B).withOpacity(0.45) : const Color(0xFFF0FDF4);
  }

  static Color get cardSky {
    if (isPeach) return const Color(0xFFFFECE2);
    return isDark ? const Color(0xFF0C4A6E).withOpacity(0.45) : const Color(0xFFF0F9FF);
  }

  static Color get cardLavender {
    if (isPeach) return const Color(0xFFFFF5F0);
    return isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  }

  static Color get cardPeach {
    if (isPeach) return const Color(0xFFFFE8DC);
    return isDark ? const Color(0xFF4E2214).withOpacity(0.55) : const Color(0xFFFFF3ED);
  }

  static Color get cardPeachBorder {
    if (isPeach) return const Color(0xFFFFC5AC);
    return isDark ? const Color(0xFFBF360C).withOpacity(0.4) : const Color(0xFFFFD7C7);
  }

  static Color get cardPeachSurface {
    if (isPeach) return const Color(0xFFFFF9F5);
    return isDark ? const Color(0xFF26130C) : const Color(0xFFFFF9F5);
  }

  // Dynamic Theme Accents & Badges
  static Color get accentGreen {
    if (isPeach) return const Color(0xFFE64A19);
    return isDark ? const Color(0xFF10B981) : const Color(0xFF0F5132);
  }

  static Color get accentGreenLight {
    if (isPeach) return const Color(0xFFFF7043);
    return isDark ? const Color(0xFF34D399) : const Color(0xFF166534);
  }

  static Color get accentPeach => isDark ? const Color(0xFFFFAB91) : const Color(0xFFE64A19);
  static Color get accentPeachLight => isDark ? const Color(0xFFFFCCBC) : const Color(0xFFF4511E);

  // Status Badges Colors (Luminous in Dark, Crisp in Light, Cozy in Peach)
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

  // Status Badges Colors for Peach
  static Color get badgePeachBg {
    if (isPeach) return const Color(0xFFFFDEC9);
    return isDark ? const Color(0xFF5E2616).withOpacity(0.55) : const Color(0xFFFFEDE4);
  }

  static Color get badgePeachText {
    if (isPeach) return const Color(0xFFBF360C);
    return isDark ? const Color(0xFFFFAB91) : const Color(0xFFD84315);
  }

  static Color get badgePeachBorder {
    if (isPeach) return const Color(0xFFFFB899);
    return isDark ? const Color(0xFFFF7043).withOpacity(0.35) : const Color(0xFFFFCCBC);
  }

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

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFFF8A65), Color(0xFFFF7043)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softPeachGradient = LinearGradient(
    colors: [Color(0xFFFFF3ED), Color(0xFFFFE0D2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPeachGradient = LinearGradient(
    colors: [Color(0xFF3E1C12), Color(0xFF26120B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light Theme Configuration (Warm Cream Canvas with Emerald & Peach Accents)
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFAF7F4),
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandGreen,
      brightness: Brightness.light,
      primary: brandGreen,
      secondary: brandTeal,
      tertiary: brandPeach,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
      outline: const Color(0xFFEFE4DC),
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFAF7F4),
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
        side: const BorderSide(color: Color(0xFFEFE4DC)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEFE4DC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFEFE4DC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFAF7F4),
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
        side: const BorderSide(color: Color(0xFFEFE4DC)),
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
      color: Color(0xFFEFE4DC),
      thickness: 1,
    ),
  );

  /// Dark Theme Configuration - Midnight Obsidian Palette with Peach & Emerald Highlights
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
      tertiary: brandPeachLight,
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

  /// Warm Peach Theme Configuration (Cozy Harvest Peach Canvas)
  static final ThemeData peachTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFFFF7F2),
    colorScheme: ColorScheme.fromSeed(
      seedColor: brandPeachDark,
      brightness: Brightness.light,
      primary: brandPeachDark,
      onPrimary: Colors.white,
      secondary: brandPeach,
      tertiary: brandGreen,
      surface: Colors.white,
      surfaceTint: Colors.transparent,
      outline: const Color(0xFFFFD5C2),
    ),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFF7F2),
      elevation: 0,
      centerTitle: false,
      foregroundColor: Color(0xFF3E1D13),
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF3E1D13),
        letterSpacing: -0.3,
      ),
      iconTheme: IconThemeData(color: Color(0xFF3E1D13)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFFFD5C2)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD5C2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD5C2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: brandPeachDark, width: 1.5),
      ),
      hintStyle: const TextStyle(color: Color(0xFFA87565), fontSize: 13.5),
      labelStyle: const TextStyle(color: Color(0xFF7A4B3A), fontSize: 13.5),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFFFFF7F2),
      indicatorColor: brandPeach.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: brandPeachDark, fontWeight: FontWeight.bold, fontSize: 12);
        }
        return const TextStyle(color: Color(0xFF7A4B3A), fontSize: 12);
      }),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFD5C2)),
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
      color: Color(0xFFFFD5C2),
      thickness: 1,
    ),
  );
}
