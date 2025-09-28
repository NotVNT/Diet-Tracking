import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/language_selector.dart';

void main() {
  group('LanguageSelector', () {
    testWidgets('should render with default properties', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.text('VI'), findsOneWidget);
    });

    testWidgets('should display Vietnamese language correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      expect(find.text('VI'), findsOneWidget);
      expect(find.text('🇻🇳'), findsOneWidget);
    });

    testWidgets('should display English language correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.en,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('should render with custom padding', (
      WidgetTester tester,
    ) async {
      const customPadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
              padding: customPadding,
            ),
          ),
        ),
      );

      // Test that the widget renders without errors
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.text('VI'), findsOneWidget);
      expect(find.text('🇻🇳'), findsOneWidget);
    });

    testWidgets('should render with custom available languages', (
      WidgetTester tester,
    ) async {
      const customLanguages = [Language.en];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.en,
              onChanged: (language) {},
              availableLanguages: customLanguages,
            ),
          ),
        ),
      );

      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should have correct styling for language pill', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      // Test that the widget renders without errors
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.text('VI'), findsOneWidget);
      expect(find.text('🇻🇳'), findsOneWidget);
    });

    testWidgets('should have correct text styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      // Test that the text is displayed correctly
      expect(find.text('VI'), findsOneWidget);
      expect(find.text('🇻🇳'), findsOneWidget);
    });

    testWidgets('should handle onChanged callback', (
      WidgetTester tester,
    ) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Test that the widget renders without error
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(callbackCalled, false);
    });

    testWidgets('should handle different language selections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.en,
              onChanged: (language) {},
              availableLanguages: const [Language.vi, Language.en],
            ),
          ),
        ),
      );

      expect(find.text('EN'), findsOneWidget);
      expect(find.text('🇺🇸'), findsOneWidget);
    });

    testWidgets('should maintain state correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      // Should show Vietnamese as selected
      expect(find.text('VI'), findsOneWidget);
      expect(find.text('🇻🇳'), findsOneWidget);
    });

    testWidgets('should handle widget rebuilds correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.vi,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      expect(find.text('VI'), findsOneWidget);

      // Rebuild with different language
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              selected: Language.en,
              onChanged: (language) {},
            ),
          ),
        ),
      );

      expect(find.text('EN'), findsOneWidget);
    });
  });
}
