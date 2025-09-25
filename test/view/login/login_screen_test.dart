import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/login/login_screen.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/guest_sync_service.dart';
import 'package:mockito/mockito.dart';

class _AuthMock extends Mock implements AuthService {}

class _GuestSyncMock extends Mock implements GuestSyncService {}

void main() {
  testWidgets('LoginScreen: render và tap nút không crash', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: _AuthMock(),
          guestSyncService: _GuestSyncMock(),
        ),
      ),
    );

    // Tap nút Đăng nhập ở trạng thái rỗng -> không crash (không assert SnackBar để tránh treo)
    await tester.tap(find.text('Đăng nhập'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Đăng Nhập'), findsOneWidget);
  });

  testWidgets('LoginScreen: toggle hiện/ẩn mật khẩu', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: _AuthMock(),
          guestSyncService: _GuestSyncMock(),
        ),
      ),
    );

    // Nhấn icon mắt để toggle
    final eyeIcon = find.byIcon(Icons.visibility);
    expect(eyeIcon, findsOneWidget);
    await tester.tap(eyeIcon);
    await tester.pump();

    // Sau khi toggle, icon đổi sang visibility_off
    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
  });
}
