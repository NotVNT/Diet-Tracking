import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';

void main() {
  group('WeightSelector', () {
    testWidgets('Render và điều hướng tiếp theo', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: WeightSelector()));

      // Tránh phụ thuộc chuỗi theo ngôn ngữ; chỉ tìm nút hành động chính
      expect(find.byType(ElevatedButton), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(GoalWeightSelector), findsOneWidget);
    });
  });
}
