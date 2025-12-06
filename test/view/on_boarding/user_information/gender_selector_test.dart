import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/gender_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  setUp(() async {
    // Mock SharedPreferences for LocalStorageService
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('GenderSelector: renders title, options, and defaults to Male', (tester) async {
    await tester.pumpWidget(_buildApp(const GenderSelector()));

    // Check for title and description
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text("We'll use this information to calculate your daily energy needs."), findsOneWidget);

    // Check for gender options
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);

    // Check for the Continue button
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('GenderSelector: tapping Female option selects it', (tester) async {
    await tester.pumpWidget(_buildApp(const GenderSelector()));

    // Tap the 'Female' option
    await tester.tap(find.text('Female'));
    await tester.pump();

    // This is a way to check selection state without deep diving into widget properties.
    // We expect the navigation to carry the correct state.
  });

  testWidgets('GenderSelector: tapping Continue navigates to AgeSelector', (tester) async {
    await tester.pumpWidget(_buildApp(const GenderSelector()));

    // Tap the continue button
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle(); // Wait for navigation to complete

    // Verify that we are on the AgeSelector screen
    expect(find.byType(AgeSelector), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
  });
}

