import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Central theme mode controller for the Farm2Factory application.
/// Manages ThemePreference (Light, Dark, System Auto, and Warm Peach) and persists selection
/// across app restarts using SharedPreferences.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const String _prefKey = 'f2f_theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  String _preference = 'system'; // 'system', 'light', 'dark', 'peach'

  ThemeMode get themeMode => _themeMode;
  String get themePreference => _preference;
  bool get isPeach => _preference == 'peach';

  /// Returns true if dark mode is active either explicitly or via system brightness.
  bool get isDark {
    if (isPeach) return false;
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
        _preference = 'dark';
        _themeMode = ThemeMode.dark;
      } else if (saved == 'light') {
        _preference = 'light';
        _themeMode = ThemeMode.light;
      } else if (saved == 'peach') {
        _preference = 'peach';
        _themeMode = ThemeMode.light;
      } else {
        _preference = 'system';
        _themeMode = ThemeMode.system;
      }
    } catch (_) {
      _preference = 'system';
      _themeMode = ThemeMode.system;
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system && !isPeach) {
      notifyListeners();
    }
  }

  /// Set the theme preference ('system', 'light', 'dark', 'peach') and persist to storage.
  Future<void> setThemePreference(String pref) async {
    if (_preference == pref) return;
    _preference = pref;
    if (pref == 'peach') {
      _themeMode = ThemeMode.light;
    } else if (pref == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (pref == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, pref);
    } catch (_) {}
  }

  /// Set standard Flutter ThemeMode (maintains backward compatibility).
  Future<void> setThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.dark:
        await setThemePreference('dark');
        break;
      case ThemeMode.light:
        await setThemePreference('light');
        break;
      case ThemeMode.system:
        await setThemePreference('system');
        break;
    }
  }

  /// Quick toggle between Light, Dark, and Warm Peach modes.
  Future<void> toggleTheme() async {
    if (isPeach) {
      await setThemePreference('dark');
    } else if (isDark) {
      await setThemePreference('light');
    } else {
      await setThemePreference('peach');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
