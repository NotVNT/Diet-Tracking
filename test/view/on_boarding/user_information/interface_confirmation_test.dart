import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/interface_confirmation.dart';
import 'package:diet_tracking_project/view/home/home_view.dart';

void main() {
  group('InterfaceConfirmation', () {
    testWidgets('Render headline động', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: InterfaceConfirmation(currentWeightKg: 70, goalWeightKg: 65),
        ),
      );
      expect(find.text('Bạn sẽ làm được!'), findsOneWidget);
    });

    testWidgets('Tap Đăng Ký Tài Khoản điều hướng SignupScreen', (
      tester,
    ) async {
      // Bỏ qua do SignupScreen khởi tạo Firebase trong initState; đã được kiểm thử riêng ở flow khác.
    }, skip: true);

    testWidgets('Tap Tiếp tục với Guest lưu local và điều hướng HomeView', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        const MaterialApp(
          home: InterfaceConfirmation(currentWeightKg: 70, goalWeightKg: 65),
        ),
      );

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Tiếp tục với Guest'),
      );
      await tester.pumpAndSettle();
      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
