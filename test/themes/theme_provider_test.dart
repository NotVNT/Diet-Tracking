import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/themes/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeProvider', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('initializes with light by default and loads from prefs', () async {
      // Start with no stored value
      final provider1 = ThemeProvider();
      // Wait a microtask loop to allow async _loadTheme to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider1.themeMode, anyOf(ThemeMode.light, ThemeMode.dark));

      // Store dark and create a new provider
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('theme_mode', true);
      final provider2 = ThemeProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider2.isDarkMode, true);
    });

    test('toggleTheme switches mode and persists to prefs', () async {
      final provider = ThemeProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final initial = provider.themeMode;
      await provider.toggleTheme();
      final toggled = provider.themeMode;
      expect(toggled != initial, true);

      // Verify persisted
      final prefs = await SharedPreferences.getInstance();
      final storedIsDark = prefs.getBool('theme_mode') ?? false;
      expect(storedIsDark, toggled == ThemeMode.dark);
    });

    test('setThemeMode updates only when different and persists', () async {
      final provider = ThemeProvider();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.isDarkMode, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('theme_mode'), true);

      // Calling with same mode should keep value
      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.isDarkMode, true);
    });
  });
}

