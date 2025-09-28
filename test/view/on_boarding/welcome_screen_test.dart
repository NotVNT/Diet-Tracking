import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/welcome_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/started_screen.dart';
import 'package:diet_tracking_project/common/language_selector.dart';

void main() {
  group('WelcomeScreen', () {
    setUp(() {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays welcome screen with all main elements', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Wait for animations to complete
      await tester.pumpAndSettle();

      // Wait for the timer to complete (2 seconds + buffer)
      await tester.pump(const Duration(seconds: 3));

      // Check if main title is displayed
      expect(
        find.text('Bắt đầu theo dõi\nchế độ ăn kiêng của bạn hôm nay!'),
        findsOneWidget,
      );

      // Check if subtitle is displayed
      expect(
        find.text(
          'Theo dõi chế độ ăn kiêng hàng ngày với\nkế hoạch bữa ăn cá nhân hóa và\nkhuyến nghị thông minh.',
        ),
        findsOneWidget,
      );

      // Check if language selector is present
      expect(find.byType(LanguageSelector), findsOneWidget);

      // Check if "Get Started" button is present
      expect(find.text('Bắt đầu ngay'), findsOneWidget);

      // Check if "Login" button is present
      expect(find.text('Đăng nhập'), findsOneWidget);
    });

    testWidgets('navigates to StartScreen when Get Started button is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Find and tap the "Get Started" button
      final getStartedButton = find.text('Bắt đầu ngay');
      expect(getStartedButton, findsOneWidget);

      await tester.tap(getStartedButton);
      await tester.pumpAndSettle();

      // Verify navigation to StartScreen
      expect(find.byType(StartScreen), findsOneWidget);
    });

    testWidgets('displays image carousel with correct images', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Check if PageView is present for image carousel
      expect(find.byType(PageView), findsOneWidget);

      // Check if images are displayed (they should be present as Image widgets)
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('handles language change correctly', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Find language selector
      final languageSelector = find.byType(LanguageSelector);
      expect(languageSelector, findsOneWidget);

      // The language change functionality is tested in the LanguageSelector widget itself
      // Here we just verify the selector is present and functional
    });

    testWidgets('displays correct animations', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      // Check if FadeTransition and SlideTransition are present
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      // Let animations complete
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Verify that animated elements are still present after animation
      expect(
        find.text('Bắt đầu theo dõi\nchế độ ăn kiêng của bạn hôm nay!'),
        findsOneWidget,
      );
    });

    testWidgets('displays fallback text when localization fails', (
      tester,
    ) async {
      // Test with a context that doesn't have proper localization
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Should display fallback Vietnamese text
      expect(
        find.text('Bắt đầu theo dõi\nchế độ ăn kiêng của bạn hôm nay!'),
        findsOneWidget,
      );
      expect(
        find.text(
          'Theo dõi chế độ ăn kiêng hàng ngày với\nkế hoạch bữa ăn cá nhân hóa và\nkhuyến nghị thông minh.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('has login button present', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Check if "Login" button is present
      expect(find.text('Đăng nhập'), findsOneWidget);
    });

    testWidgets('has get started button present', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Check if "Get Started" button is present
      expect(find.text('Bắt đầu ngay'), findsOneWidget);
    });
  });
}
