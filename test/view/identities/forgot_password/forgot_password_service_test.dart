import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_service.dart';

void main() {
  group('PasswordResetResult', () {
    test('success factory sets flags and email', () {
      final r = PasswordResetResult.success(emailUsed: 'x@y.com');
      expect(r.isSuccess, true);
      expect(r.emailUsed, 'x@y.com');
      expect(r.errorCode, isNull);
      expect(r.error, isNull); // backward-compat getter
    });

    test('failure factory sets code and additionalInfo', () {
      final r = PasswordResetResult.failure(
        ForgotPasswordErrorCode.accountUsesProvider,
        additionalInfo: 'Google',
      );
      expect(r.isSuccess, false);
      expect(r.errorCode, ForgotPasswordErrorCode.accountUsesProvider);
      expect(r.additionalInfo, 'Google');
    });
  });
}
