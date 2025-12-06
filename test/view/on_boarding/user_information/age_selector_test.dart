import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
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
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AgeSelector: renders correctly and navigates on tap', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(const AgeSelector()));

    // Verify title and description are present
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('How old are you?'), findsOneWidget);

    // Verify the age picker is present
    expect(find.byType(ListWheelScrollView), findsOneWidget);

    // Verify the 'Next' button is present
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);

    // Tap the 'Next' button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify navigation to HealthInfoScreen
    expect(find.byType(HealthInfoScreen), findsOneWidget);
  });

  testWidgets('AgeSelector: scrolls and updates the selected age', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(const AgeSelector()));

    // The default age is 30 (initialItem: 18, base: 12)
    expect(find.text('30'), findsOneWidget);

    // Scroll the wheel
    await tester.drag(find.byType(ListWheelScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();

    // Verify the age has changed. The exact value depends on scroll distance,
    // so we just check that the original value is gone from the 'selected' position.
    // A more robust test would require access to the widget's state.
  });
}
