import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/height_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
import 'package:diet_tracking_project/database/auth_service.dart';

void main() {
  group('AgeSelector', () {
    testWidgets('Render và điều hướng tiếp theo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: AgeSelector()));

      expect(find.text('Tuổi'), findsOneWidget);

      // Nhấn Tiếp theo
      await tester.tap(find.text('Tiếp theo'));
      await tester.pumpAndSettle();
      // App điều hướng sang HealthInfoScreen theo code hiện tại
      expect(find.byType(HealthInfoScreen), findsOneWidget);
    });
  });
}
