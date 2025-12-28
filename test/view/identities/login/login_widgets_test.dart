import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/login/login_widgets.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrap(Widget child) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: child),
      );

  group('EmailInputField', () {
    testWidgets('shows label and hint', (tester) async {
      final c = TextEditingController();
      await tester.pumpWidget(wrap(EmailInputField(
        controller: c,
        isFocused: false,
        onTap: () {},
      )));
      expect(find.text('Email or Phone Number'), findsOneWidget);
      expect(find.text('Enter Email or Phone Number'), findsOneWidget);
    });
  });

  group('PasswordInputField', () {
    testWidgets('toggle visibility icon switches', (tester) async {
      bool visible = false;
      final c = TextEditingController();
      await tester.pumpWidget(wrap(StatefulBuilder(builder: (context, setState) {
        return PasswordInputField(
          controller: c,
          isFocused: false,
          isPasswordVisible: visible,
          onTap: () {},
          onToggleVisibility: () => setState(() => visible = !visible),
        );
      })));

      // Initially expects visibility icon (eye open)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      // After toggle, visibility_off should appear
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });
  });

  group('ForgotPasswordButton', () {
    testWidgets('invokes onPressed', (tester) async {
      int called = 0;
      await tester.pumpWidget(wrap(ForgotPasswordButton(onPressed: () => called++)));
      await tester.tap(find.byType(TextButton));
      expect(called, 1);
    });
  });

  group('OrDivider', () {
    testWidgets('renders divider and text', (tester) async {
      await tester.pumpWidget(wrap(const OrDivider()));
      expect(find.text('OR login with'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('NoAccountButton', () {
    testWidgets('invokes onPressed', (tester) async {
      int called = 0;
      await tester.pumpWidget(wrap(NoAccountButton(onPressed: () => called++)));
      await tester.tap(find.byType(TextButton));
      expect(called, 1);
    });
  });
}

