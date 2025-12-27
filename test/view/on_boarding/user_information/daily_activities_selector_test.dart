import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/daily_activities_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/target_days_selector.dart';

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
    SharedPreferences.setMockInitialValues({
      // Provide the required guest fields so the next screen (TargetDaysSelector)
      // can load without showing an error view.
      'guest_age': 30,
      'guest_gender': 'Male',
      'guest_height_cm': 175.0,
      'guest_weight_kg': 80.0,
      'guest_goal_weight_kg': 75.0,
      // activity level will be written by DailyActivitiesSelector
    });
  });

  testWidgets(
    'DailyActivitiesSelector: next disabled until selection, then navigates',
    (tester) async {
      await tester.pumpWidget(_buildApp(const DailyActivitiesSelector()));

      // Next button is disabled initially.
      final nextFinder = find.widgetWithText(ElevatedButton, 'Next');
      expect(nextFinder, findsOneWidget);
      expect(tester.widget<ElevatedButton>(nextFinder).onPressed, isNull);

      // Tap the first activity option.
      final optionFinder = find.byType(GestureDetector).first;
      expect(optionFinder, findsOneWidget);
      await tester.tap(optionFinder);
      await tester.pump();

      // Next button becomes enabled.
      expect(tester.widget<ElevatedButton>(nextFinder).onPressed, isNotNull);

      // Navigate.
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(find.byType(TargetDaysSelector), findsOneWidget);
    },
  );
}
