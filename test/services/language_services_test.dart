import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/common/language_selector.dart';
import 'package:diet_tracking_project/services/language_service.dart';

void main() {
  group('LanguageService Tests', () {
    // Setup for each test
    setUp(() {
      // Initialize Flutter binding for SharedPreferences
      TestWidgetsFlutterBinding.ensureInitialized();
      // Clear any existing listeners
      // Note: We can't directly access private members, so we'll handle this in individual tests
    });

    test(
      'initialize with no saved language sets default to Vietnamese',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues({});

        // Act
        await LanguageService.initialize();

        // Assert
        expect(LanguageService.currentLanguage, Language.vi);
        expect(LanguageService.currentLocale, const Locale('vi'));
        expect(LanguageService.isVietnamese, true);
        expect(LanguageService.isEnglish, false);
      },
    );

    test('initialize with saved English language', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'selected_language': 'en'});

      // Act
      await LanguageService.initialize();

      // Assert
      expect(LanguageService.currentLanguage, Language.en);
      expect(LanguageService.currentLocale, const Locale('en'));
      expect(LanguageService.isVietnamese, false);
      expect(LanguageService.isEnglish, true);
    });

    test('changeLanguage updates language and saves to preferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      await LanguageService.changeLanguage(Language.en);

      // Assert
      expect(LanguageService.currentLanguage, Language.en);
      expect(LanguageService.currentLocale, const Locale('en'));
      expect(LanguageService.isVietnamese, false);
      expect(LanguageService.isEnglish, true);
    });

    test('changeLanguage notifies listeners', () async {
      // Arrange
      int callCount = 0;
      void listener() => callCount++;
      LanguageService.addLanguageListener(listener);
      SharedPreferences.setMockInitialValues({});

      // Act
      await LanguageService.changeLanguage(Language.en);

      // Assert
      expect(callCount, greaterThanOrEqualTo(1));

      // Clean up
      LanguageService.removeLanguageListener(listener);
    });

    test(
      'addLanguageListener and removeLanguageListener work correctly',
      () async {
        // Arrange
        int callCount1 = 0;
        int callCount2 = 0;
        void listener1() => callCount1++;
        void listener2() => callCount2++;

        // Act
        LanguageService.addLanguageListener(listener1);
        LanguageService.addLanguageListener(listener2);
        await LanguageService.changeLanguage(Language.en);

        LanguageService.removeLanguageListener(listener2);
        await LanguageService.changeLanguage(Language.vi);

        // Assert
        expect(
          callCount1,
          greaterThanOrEqualTo(2),
        ); // Should be called at least twice
        expect(
          callCount2,
          greaterThanOrEqualTo(1),
        ); // Should be called at least once

        // Clean up
        LanguageService.removeLanguageListener(listener1);
      },
    );

    test('currentLocale returns correct locale for Vietnamese', () async {
      // Arrange
      await LanguageService.changeLanguage(Language.vi);

      // Act
      final locale = LanguageService.currentLocale;

      // Assert
      expect(locale, const Locale('vi'));
    });

    test('currentLocale returns correct locale for English', () async {
      // Arrange
      await LanguageService.changeLanguage(Language.en);

      // Act
      final locale = LanguageService.currentLocale;

      // Assert
      expect(locale, const Locale('en'));
    });

    test('isVietnamese returns true when language is Vietnamese', () async {
      // Arrange
      await LanguageService.changeLanguage(Language.vi);

      // Act & Assert
      expect(LanguageService.isVietnamese, true);
      expect(LanguageService.isEnglish, false);
    });

    test('isEnglish returns true when language is English', () async {
      // Arrange
      await LanguageService.changeLanguage(Language.en);

      // Act & Assert
      expect(LanguageService.isVietnamese, false);
      expect(LanguageService.isEnglish, true);
    });
  });
}
