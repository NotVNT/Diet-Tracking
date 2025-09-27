import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/language_selector.dart';

/// Service to manage language preferences and localization
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static Language _currentLanguage = Language.vi;
  static final List<VoidCallback> _listeners = [];

  /// Get the current language
  static Language get currentLanguage => _currentLanguage;

  /// Initialize language service and load saved preference
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage != null) {
      _currentLanguage = Language.values.firstWhere(
        (lang) => lang.name == savedLanguage,
        orElse: () => Language.vi,
      );
    }
  }

  /// Change the current language and save to preferences
  static Future<void> changeLanguage(Language language) async {
    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.name);

    // Notify all listeners
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Add a listener for language changes
  static void addLanguageListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Remove a listener for language changes
  static void removeLanguageListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Get the current locale based on the selected language
  static Locale get currentLocale {
    switch (_currentLanguage) {
      case Language.vi:
        return const Locale('vi');
      case Language.en:
        return const Locale('en');
    }
  }

  /// Check if the current language is Vietnamese
  static bool get isVietnamese => _currentLanguage == Language.vi;

  /// Check if the current language is English
  static bool get isEnglish => _currentLanguage == Language.en;
}
