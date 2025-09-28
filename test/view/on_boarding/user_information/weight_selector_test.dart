import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';

void main() {
  group('WeightSelector', () {
    testWidgets('Render và điều hướng tiếp theo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: WeightSelector()));

      expect(find.text('Cân nặng'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tiếp theo'));
      await tester.pumpAndSettle();
      expect(find.byType(GoalWeightSelector), findsOneWidget);
    });
  });
}
