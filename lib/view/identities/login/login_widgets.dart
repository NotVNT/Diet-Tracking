import 'package:flutter/material.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_input_field.dart';
import '../../../common/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Widget cho email input field
class EmailInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final VoidCallback onTap;

  const EmailInputField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: AppLocalizations.of(context)?.emailOrPhone ?? 'Email hoặc Số Điện Thoại',
      hint: AppLocalizations.of(context)?.emailOrPhoneHint ?? 'Nhập Email hoặc Số Điện Thoại',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      isFocused: isFocused,
      onTap: onTap,
    );
  }
}

/// Widget cho password input field
class PasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final bool isPasswordVisible;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;

  const PasswordInputField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.isPasswordVisible,
    required this.onTap,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: AppLocalizations.of(context)?.password ?? 'Mật khẩu',
      controller: controller,
      obscureText: !isPasswordVisible,
      isFocused: isFocused,
      onTap: onTap,
      suffixIcon: IconButton(
        icon: Icon(
          isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: AppColors.grey600,
          size: 20,
        ),
        onPressed: onToggleVisibility,
      ),
    );
  }
}

/// Widget cho forgot password button
class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ForgotPasswordButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          AppLocalizations.of(context)?.forgotPassword ?? 'Quên mật khẩu?',
          style: AppStyles.linkText,
        ),
      ),
    );
  }
}

/// Widget cho divider "hoặc đăng nhập bằng"
class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)?.orLoginWith ?? 'HOẶC đăng nhập bằng',
            style: AppStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

/// Widget cho "Tôi chưa có tài khoản" button
class NoAccountButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NoAccountButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          AppLocalizations.of(context)?.dontHaveAccount ?? 'Tôi chưa có tài khoản',
          style: AppStyles.linkText.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
