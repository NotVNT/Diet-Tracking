import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/gender_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';

void main() {
  group('GenderSelector', () {
    testWidgets('Render và đổi lựa chọn', (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: GenderSelector()));

      // Tránh phụ thuộc văn bản theo ngôn ngữ
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.text('Nữ'));
      await tester.pump();

      // Nút hành động chính điều hướng
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(AgeSelector), findsOneWidget);
    });
  });
}
