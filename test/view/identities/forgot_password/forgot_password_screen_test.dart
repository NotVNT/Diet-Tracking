import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_screen.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _appWithRoute(Widget home) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: home,
    );
  }

  group('ForgotPasswordScreen UI', () {
    testWidgets(
      'renders title, instruction, email field, send button and back link',
      (tester) async {
        await tester.pumpWidget(_appWithRoute(const ForgotPasswordScreen()));

        // Title
        expect(find.text('Forgot Password?'), findsOneWidget);
        // Instruction text
        expect(
          find.text(
            "Enter your email and we'll send you instructions to reset your password.",
          ),
          findsOneWidget,
        );
        // Email label and hint
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('example@gmail.com'), findsOneWidget);
        // Send button
        expect(find.text('Send Reset Email'), findsOneWidget);
        // Back to login link
        expect(find.text('Back to Login'), findsOneWidget);
      },
    );

    testWidgets('leading back button pops Navigator', (tester) async {
      final navKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const ForgotPasswordScreen(),
        ),
      );

      // Push a dummy second route to ensure pop works
      navKey.currentState!.push(
        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
      );
      await tester.pumpAndSettle();

      // Tap back arrow
      final backBtn = find.byIcon(Icons.arrow_back);
      expect(backBtn, findsOneWidget);
      await tester.tap(backBtn);
      await tester.pumpAndSettle();

      // After pop, we should still have one ForgotPasswordScreen in tree
      expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    });

    testWidgets('Back to Login link pops Navigator', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          routes: {
            '/': (_) => const Scaffold(body: Center(child: Text('Home'))),
            '/forgot': (_) => const ForgotPasswordScreen(),
          },
          initialRoute: '/forgot',
        ),
      );

      // Tap Back to Login link
      await tester.tap(find.text('Back to Login'));
      await tester.pumpAndSettle();

      // We should navigate back to Home screen
      expect(find.text('Home'), findsOneWidget);
    });
  });
}
