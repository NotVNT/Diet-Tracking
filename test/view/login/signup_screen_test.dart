import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/login/signup_screen.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/guest_sync_service.dart';
import 'package:mockito/mockito.dart';

class _AuthMock extends Mock implements AuthService {}

class _GuestSyncMock extends Mock implements GuestSyncService {}

void main() {
  testWidgets('SignupScreen: render và tap nút không crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupScreen(
          authService: _AuthMock(),
          guestSyncService: _GuestSyncMock(),
        ),
      ),
    );

    // Đảm bảo văn bản hiển thị
    expect(find.text('Tạo tài khoản'), findsOneWidget);
    // Thử tap 'Đăng ký' (nút có thể disabled, mục tiêu là không crash)
    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tạo tài khoản'), findsOneWidget);
  });

  testWidgets('SignupScreen: nhập liệu các trường cơ bản không crash', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignupScreen(
          authService: _AuthMock(),
          guestSyncService: _GuestSyncMock(),
        ),
      ),
    );

    // Các TextField lần lượt: Họ và tên(0), Số điện thoại(1), Email(2), Mật khẩu(3), Nhập lại mật khẩu(4)
    final nameField = find.byType(TextField).at(0);
    final phoneField = find.byType(TextField).at(1);
    final emailField = find.byType(TextField).at(2);
    final passField = find.byType(TextField).at(3);
    final confirmField = find.byType(TextField).at(4);

    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'A');

    await tester.ensureVisible(phoneField);
    await tester.enterText(phoneField, '0123');

    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'a@a.com');

    await tester.ensureVisible(passField);
    await tester.enterText(passField, '123456');

    await tester.ensureVisible(confirmField);
    await tester.enterText(confirmField, '123456');
    await tester.ensureVisible(find.text('Đăng ký'));
    await tester.tap(find.text('Đăng ký'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Tạo tài khoản'), findsOneWidget);
  });
}
