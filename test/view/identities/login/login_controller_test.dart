import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/login/login_controller.dart';

void main() {
  group('LoginController validation', () {
    final ctl = LoginController();

    test('validateEmail returns error for null/empty', () {
      expect(ctl.validateEmail(null), LoginErrorCode.emptyEmail);
      expect(ctl.validateEmail(''), LoginErrorCode.emptyEmail);
      expect(ctl.validateEmail('   '), LoginErrorCode.emptyEmail);
    });

    test('validateEmail returns null for non-empty', () {
      expect(ctl.validateEmail('a@b.com'), isNull);
    });

    test('validatePassword returns error for null/empty', () {
      expect(ctl.validatePassword(null), LoginErrorCode.emptyPassword);
      expect(ctl.validatePassword(''), LoginErrorCode.emptyPassword);
      expect(ctl.validatePassword('   '), LoginErrorCode.emptyPassword);
    });

    test('validatePassword returns null for non-empty', () {
      expect(ctl.validatePassword('123'), isNull);
    });

    test('signInWithEmailPassword short-circuits on validation (no services)', () async {
      final res1 = await ctl.signInWithEmailPassword();
      expect(res1.isSuccess, false);
      expect(res1.errorCode, LoginErrorCode.emptyEmail);

      ctl.emailController.text = 'user@example.com';
      final res2 = await ctl.signInWithEmailPassword();
      expect(res2.isSuccess, false);
      expect(res2.errorCode, LoginErrorCode.emptyPassword);
    });
  });
}

