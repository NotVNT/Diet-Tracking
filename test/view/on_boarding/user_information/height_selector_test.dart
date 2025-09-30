import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/height_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';

void main() {
  group('HeightSelector', () {
    testWidgets('Render và điều hướng tiếp theo', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Tăng kích thước bề mặt để tránh tràn bố cục khi điều hướng sang WeightSelector
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: HeightSelector()));

      // Tránh phụ thuộc vào chuỗi theo ngôn ngữ, chỉ cần tìm nút hành động chính
      expect(find.byType(ElevatedButton), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(WeightSelector), findsOneWidget);
    });
  });
}
