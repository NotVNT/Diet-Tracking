import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/common/custom_button.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_screen.dart';
import 'package:diet_tracking_project/view/identities/login/login_main_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/started_screen.dart';

Widget _wrapWithApp(Widget widget) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: widget,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('LoginScreen basic UI', () {
    // Mock SharedPreferences to ensure deterministic behavior for hasGuestData()
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('renders key texts and buttons', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340); // Taller screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));

      final titleFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.data == 'Login' &&
            widget.style?.fontWeight == FontWeight.w700,
      );

      expect(titleFinder, findsOneWidget);
      expect(find.text('Email or Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.widgetWithText(CustomButton, 'Login'), findsOneWidget);
      expect(find.text('OR login with'), findsOneWidget);
      expect(
        find.widgetWithText(CustomButton, 'Continue with Google'),
        findsOneWidget,
      );
      expect(find.text("I don't have an account"), findsOneWidget);
    });

    testWidgets('tapping Forgot password navigates to ForgotPasswordScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('no account button navigates to onboarding StartScreen', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text("I don't have an account"));
      await tester.tap(find.text("I don't have an account"));
      await tester.pumpAndSettle();
      expect(find.byType(StartScreen), findsOneWidget);
    });

    testWidgets('login button with empty fields shows error snackbar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2340); // Taller screen
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_wrapWithApp(const LoginScreen()));
      await tester.pump(const Duration(milliseconds: 1300));
      await tester.pumpAndSettle(); // Wait for animations to complete

      final loginButton = find.widgetWithText(CustomButton, 'Login');
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();
      await tester.tap(loginButton, warnIfMissed: false);
      await tester.pump(); // Let snackbar animation run
      expect(find.text('Please enter email'), findsOneWidget);
    });
  });
}
