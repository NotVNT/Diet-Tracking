import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/gender_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/age_selector.dart';

void main() {
  group('GenderSelector', () {
    testWidgets('Render và đổi lựa chọn', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const MaterialApp(home: GenderSelector()));

      expect(find.text('Giới tính'), findsOneWidget);
      expect(find.text('Nam'), findsOneWidget);
      expect(find.text('Nữ'), findsOneWidget);

      await tester.tap(find.text('Nữ'));
      await tester.pump();

      // Nút Tiếp tục khả dụng và điều hướng
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tiếp tục'));
      await tester.pumpAndSettle();
      expect(find.byType(AgeSelector), findsOneWidget);
    });
  });
}
