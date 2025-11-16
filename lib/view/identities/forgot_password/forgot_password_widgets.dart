import 'package:flutter/material.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_input_field.dart';
import '../../../l10n/app_localizations.dart';

/// Widget cho email input field
class ForgotPasswordEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final VoidCallback onTap;

  const ForgotPasswordEmailField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: AppLocalizations.of(context)?.email ?? 'Email',
      hint: AppLocalizations.of(context)?.emailHint ?? 'example@gmail.com',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      isFocused: isFocused,
      onTap: onTap,
    );
  }
}

/// Widget cho instruction text
class ForgotPasswordInstruction extends StatelessWidget {
  const ForgotPasswordInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)?.forgotPasswordInstruction ??
          'Nhập email của bạn và chúng tôi sẽ gửi cho bạn hướng dẫn để đặt lại mật khẩu.',
      style: AppStyles.bodyMedium.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// Widget cho back to login link
class BackToLoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const BackToLoginLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onTap,
        child: Text(
          AppLocalizations.of(context)?.backToLogin ?? 'Quay lại đăng nhập',
          style: AppStyles.linkText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
