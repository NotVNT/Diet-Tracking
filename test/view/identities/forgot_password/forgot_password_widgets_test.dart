import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_widgets.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: Scaffold(body: child),
    );
  }

  group('ForgotPasswordEmailField', () {
    testWidgets('shows localized label and hint', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(
        _wrap(
          ForgotPasswordEmailField(
            controller: controller,
            isFocused: false,
            onTap: () {},
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      // Hint text
      expect(find.text('example@gmail.com'), findsOneWidget);
    });
  });

  group('ForgotPasswordInstruction', () {
    testWidgets('shows localized instruction', (tester) async {
      await tester.pumpWidget(_wrap(const ForgotPasswordInstruction()));
      expect(
        find.text('Enter your email and we\'ll send you instructions to reset your password.'),
        findsOneWidget,
      );
    });
  });

  group('BackToLoginLink', () {
    testWidgets('taps call onTap', (tester) async {
      int tapped = 0;
      await tester.pumpWidget(
        _wrap(
          BackToLoginLink(onTap: () => tapped++),
        ),
      );

      await tester.tap(find.byType(TextButton));
      expect(tapped, 1);
    });
  });
}

