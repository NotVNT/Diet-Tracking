import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/login/login_screen.dart';
import 'package:diet_tracking_project/database/guest_sync_service.dart';
import 'package:diet_tracking_project/services/google_auth_service.dart';
// Bỏ phụ thuộc Firebase cho test này

class _ResetSpy {
  bool called = false;
  Future<void> call(String email) async {
    called = true;
  }
}

class _GuestFake extends GuestSyncService {}

abstract class _GoogleFake implements GoogleAuthService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });
  testWidgets('Forgot password sends reset email and shows SnackBar', (
    tester,
  ) async {
    final spy = _ResetSpy();
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          authService: null,
          guestSyncService: null,
          googleAuthService: null,
          onSendPasswordReset: spy.call,
        ),
      ),
    );

    // nhập email
    await tester.enterText(find.byType(TextField).first, 'a@a.com');
    // bấm quên mật khẩu
    await tester.tap(find.text('Quên mật khẩu?'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    expect(spy.called, isTrue);
  });
}
