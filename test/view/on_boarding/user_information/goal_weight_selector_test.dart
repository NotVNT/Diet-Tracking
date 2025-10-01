import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/interface_confirmation.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('GoalWeightSelector', () {
    testWidgets('Render và điều hướng InterfaceConfirmation', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          home: GoalWeightSelector(
            currentWeightKg: 70,
            authService: null,
            localStorageService: LocalStorageService(),
          ),
        ),
      );

      // Không phụ thuộc chuỗi theo ngôn ngữ; bấm nút hành động chính
      expect(find.text('Xong'), findsOneWidget);
      await tester.tap(find.text('Xong'));
      await tester.pumpAndSettle();
      expect(find.byType(InterfaceConfirmation), findsOneWidget);
    });
  });
}
