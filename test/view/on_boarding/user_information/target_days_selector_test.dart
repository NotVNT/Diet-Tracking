import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/target_days_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/nutrition_summary.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('vi'),
    home: home,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'guest_age': 30,
      'guest_gender': 'Male',
      'guest_height_cm': 175.0,
      'guest_weight_kg': 80.0,
      'guest_goal_weight_kg': 75.0,
      'guest_activity_level': 'Ít vận động',
    });
  });

  testWidgets('TargetDaysSelector: renders and navigates on next', (tester) async {
    // Give extra space to avoid overflow from cards on smaller default viewport.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(_buildApp(const TargetDaysSelector()));

    // First frame may show loading.
    await tester.pumpAndSettle();

    expect(find.text('Bạn muốn đạt mục tiêu trong bao lâu?'), findsOneWidget);
    expect(find.text('7 ngày'), findsOneWidget);

    // Change selection using quick options.
    await tester.tap(find.text('14 ngày'));
    await tester.pump();

    // Proceed.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Tiếp theo'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionSummary), findsOneWidget);
  });
}
