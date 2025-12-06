import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_controller.dart';
import 'package:diet_tracking_project/view/identities/forgot_password/forgot_password_service.dart';

class _FakeForgotPasswordService implements ForgotPasswordService {
  String? lastValidated;
  String? nextValidationResult;
  PasswordResetResult? nextResetResult;

  @override
  String? validateEmail(String? email) {
    lastValidated = email;
    return nextValidationResult;
  }

  @override
  Future<PasswordResetResult> sendPasswordResetEmail(String email) async {
    return nextResetResult ?? PasswordResetResult.success(emailUsed: email);
  }
}

void main() {
  group('ForgotPasswordController', () {
    test('validateEmail delegates to service', () {
      final fake = _FakeForgotPasswordService()
        ..nextValidationResult = ForgotPasswordErrorCode.invalidEmail;
      final ctl = ForgotPasswordController(forgotPasswordService: fake);

      final res = ctl.validateEmail('bad');
      expect(fake.lastValidated, 'bad');
      expect(res, ForgotPasswordErrorCode.invalidEmail);
    });

    test(
      'sendPasswordResetEmail uses controller text and returns result',
      () async {
        final fake = _FakeForgotPasswordService()
          ..nextResetResult = PasswordResetResult.success(
            emailUsed: 'u@example.com',
          );
        final ctl = ForgotPasswordController(forgotPasswordService: fake);
        ctl.emailController.text = 'u@example.com';

        final res = await ctl.sendPasswordResetEmail();
        expect(res.isSuccess, true);
        expect(res.emailUsed, 'u@example.com');
      },
    );
  });
}
