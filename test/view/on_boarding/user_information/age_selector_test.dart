import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/height_selector.dart';

void main() {
  group('AgeSelector', () {
    testWidgets('Render và điều hướng tiếp theo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: AgeSelector()));

      expect(find.text('Tuổi'), findsOneWidget);

      // Nhấn Tiếp theo
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tiếp theo'));
      await tester.pumpAndSettle();
      expect(find.byType(HeightSelector), findsOneWidget);
    });
  });
}
