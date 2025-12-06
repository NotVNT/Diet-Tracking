import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/user_start_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/gender_selector.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  testWidgets('UserStartScreen: renders correctly and navigates on tap', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(const StartScreen()));

    // Verify title and description are present
    expect(find.text('Tell us about yourself'), findsOneWidget);
    expect(
      find.text(
        "We'll create a personalized plan for you based on details like your age and current weight.",
      ),
      findsOneWidget,
    );

    // Verify the 'Start' button is present
    expect(find.text('Start'), findsOneWidget);

    // Tap the 'Start' button
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify navigation to GenderSelector screen
    expect(find.byType(GenderSelector), findsOneWidget);
  });
}
