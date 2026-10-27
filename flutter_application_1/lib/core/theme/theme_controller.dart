import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central theme mode controller for the Farm2Factory application.
/// Manages ThemeMode (Light, Dark, System Auto) and persists selection
/// across app restarts using SharedPreferences.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _prefKey = 'f2f_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// Returns true if dark mode is active either explicitly or via system brightness.
  bool get isDark {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  /// Initialize and load saved theme from SharedPreferences.
  Future<void> init() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    } catch (_) {
      _themeMode = ThemeMode.system;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  /// Set the theme mode and persist to storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      switch (mode) {
        case ThemeMode.dark:
          await prefs.setString(_prefKey, 'dark');
          break;
        case ThemeMode.light:
          await prefs.setString(_prefKey, 'light');
          break;
        case ThemeMode.system:
          await prefs.setString(_prefKey, 'system');
          break;
      }
    } catch (_) {}
  }

  /// Quick toggle between Light and Dark mode.
  Future<void> toggleTheme() async {
    if (isDark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
