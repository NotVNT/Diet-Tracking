import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_controller.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_screen.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_service.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_widgets.dart';

class _DelayedSuccessController extends ForgotPasswordController {
  final Duration delay;
  _DelayedSuccessController({this.delay = const Duration(milliseconds: 50)});

  @override
  String? validateEmail(String? email) => null;

  @override
  Future<PasswordResetResult> sendPasswordResetEmail() async {
    await Future<void>.delayed(delay);
    return PasswordResetResult.success();
  }
}

class _ValidationErrorController extends ForgotPasswordController {
  final String errorCode;
  _ValidationErrorController(this.errorCode);

  @override
  String? validateEmail(String? email) => errorCode;

  @override
  Future<PasswordResetResult> sendPasswordResetEmail() async {
    throw StateError('Should not be called when validation fails');
  }
}

class _FailureController extends ForgotPasswordController {
  final PasswordResetResult result;
  _FailureController(this.result);

  @override
  String? validateEmail(String? email) => null;

  @override
  Future<PasswordResetResult> sendPasswordResetEmail() async {
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget localizedApp({
    required Widget home,
    GlobalKey<NavigatorState>? navigatorKey,
    List<NavigatorObserver> observers = const <NavigatorObserver>[],
  }) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: observers,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    );
  }

  Future<void> finishIntroAnimations(WidgetTester tester) async {
    // ForgotPasswordScreen runs a 1200ms entrance animation.
    await tester.pump(const Duration(milliseconds: 1300));
  }

  group('ForgotPasswordScreen', () {
    testWidgets('renders main UI building blocks', (tester) async {
      final controller = ForgotPasswordController();
      await tester.pumpWidget(
        localizedApp(home: ForgotPasswordScreen(controller: controller)),
      );
      await finishIntroAnimations(tester);

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(
        find.text(
          "Enter your email and we'll send you instructions to reset your password.",
        ),
        findsOneWidget,
      );

      expect(find.byType(ForgotPasswordEmailField), findsOneWidget);
      expect(find.byType(ForgotPasswordInstruction), findsOneWidget);
      expect(find.byType(BackToLoginLink), findsOneWidget);

      // Label/hint come from CustomInputField.
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('example@gmail.com'), findsOneWidget);

      expect(find.text('Send Reset Email'), findsOneWidget);
      expect(find.text('Back to Login'), findsOneWidget);
    });

    testWidgets('leading back button pops to previous route', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        localizedApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(controller: ForgotPasswordController()),
        ),
      );
      await tester.pump();
      await finishIntroAnimations(tester);

      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets('Back to Login link pops to previous route', (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        localizedApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordScreen(controller: ForgotPasswordController()),
        ),
      );
      await tester.pump();
      await finishIntroAnimations(tester);

      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets('tapping send with validation error shows SnackBar', (tester) async {
      final controller = _ValidationErrorController(ForgotPasswordErrorCode.invalidEmail);
      await tester.pumpWidget(
        localizedApp(home: ForgotPasswordScreen(controller: controller)),
      );
      await finishIntroAnimations(tester);

      await tester.tap(find.text('Send Reset Email'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid email.'), findsOneWidget);
    });

    testWidgets('successful send shows loading then success dialog; OK returns back',
        (tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      final controller = _DelayedSuccessController(delay: const Duration(milliseconds: 80));

      await tester.pumpWidget(
        localizedApp(
          navigatorKey: navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      );

      navigatorKey.currentState!.push(
        MaterialPageRoute(builder: (_) => ForgotPasswordScreen(controller: controller)),
      );
      await tester.pump();
      await finishIntroAnimations(tester);

      await tester.tap(find.text('Send Reset Email'));
      await tester.pump();

      // Loading dialog should appear immediately.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the fake request complete.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(
        find.text('Password reset email sent. Please check your inbox.'),
        findsOneWidget,
      );
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // After OK: dialog closed and screen popped back to Home.
      expect(find.text('Home'), findsOneWidget);
      expect(find.byType(ForgotPasswordScreen), findsNothing);
    });

    testWidgets('failed send shows SnackBar with localized message', (tester) async {
      final controller = _FailureController(
        PasswordResetResult.failure(ForgotPasswordErrorCode.tooManyRequests),
      );
      await tester.pumpWidget(
        localizedApp(home: ForgotPasswordScreen(controller: controller)),
      );
      await finishIntroAnimations(tester);

      await tester.tap(find.text('Send Reset Email'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('Too many requests. Please try again later.'),
        findsOneWidget,
      );
    });
  });
}
