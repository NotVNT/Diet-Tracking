import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/interface_confirmation.dart';

void main() {
  group('GoalWeightSelector', () {
    testWidgets('Render và điều hướng InterfaceConfirmation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GoalWeightSelector(currentWeightKg: 70)),
      );

      expect(find.text('Cân nặng mục tiêu'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Xong'));
      await tester.pumpAndSettle();
      expect(find.byType(InterfaceConfirmation), findsOneWidget);
    });
  });
}
