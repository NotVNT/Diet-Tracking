import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  bool _isLoading = true;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Load theme from SharedPreferences
 /// Load theme from SharedPreferences
  Future<void> _loadTheme() async {
    try {

      final preferences = await SharedPreferences.getInstance(); 
      final isDark = preferences.getBool(_themeKey) ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    notifyListeners();
    await _saveTheme();
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      await _saveTheme();
    }
  }

  Future<void> _saveTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance(); 
      await preferences.setBool(_themeKey, _themeMode == ThemeMode.dark);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }
}
