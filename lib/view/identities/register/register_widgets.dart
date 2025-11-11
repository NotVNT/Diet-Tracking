import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../common/app_colors.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_input_field.dart';
import '../../../l10n/app_localizations.dart';

/// Widget cho full name input field
class FullNameInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final VoidCallback onTap;

  const FullNameInputField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: AppLocalizations.of(context)?.fullName ?? 'Họ và tên',
      hint: AppLocalizations.of(context)?.fullNameHint ?? 'Nhập họ và tên của bạn',
      controller: controller,
      isFocused: isFocused,
      onTap: onTap,
    );
  }
}

/// Widget cho phone input field
class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final VoidCallback onTap;

  const PhoneInputField({
    super.key,
    required this.controller,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      label: AppLocalizations.of(context)?.phoneNumber ?? 'Số điện thoại',
      hint: AppLocalizations.of(context)?.phoneNumberHint ?? 'Nhập số điện thoại',
      controller: controller,
      keyboardType: TextInputType.phone,
      isFocused: isFocused,
      onTap: onTap,
    );
  }
}

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
      label: AppLocalizations.of(context)?.email ?? 'Email',
      hint: AppLocalizations.of(context)?.emailHint ?? 'example@gmail.com',
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

/// Widget cho confirm password input field
class ConfirmPasswordInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isFocused;
  final bool isPasswordVisible;
  final VoidCallback onTap;
  final VoidCallback onToggleVisibility;

  const ConfirmPasswordInputField({
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
      label: AppLocalizations.of(context)?.confirmPassword ?? 'Nhập lại mật khẩu',
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

/// Widget cho terms and conditions checkbox
class TermsCheckbox extends StatelessWidget {
  final bool isAccepted;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPolicyTap;

  const TermsCheckbox({
    super.key,
    required this.isAccepted,
    required this.onChanged,
    this.onTermsTap,
    this.onPolicyTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onChanged(!isAccepted),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isAccepted ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: isAccepted ? AppColors.primary : AppColors.grey400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isAccepted
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context)?.agreeWith ?? 'Tôi đồng ý với ',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)?.termsOfService ?? 'Điều khoản sử dụng',
                  style: AppStyles.linkText.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                ),
                TextSpan(
                  text: AppLocalizations.of(context)?.and ?? ' và ',
                  style: AppStyles.bodyMedium.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)?.privacyPolicy ?? 'Chính sách bảo mật',
                  style: AppStyles.linkText.copyWith(
                    color: AppColors.primary,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = onPolicyTap,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget cho already have account link
class AlreadyHaveAccountLink extends StatelessWidget {
  final VoidCallback onTap;

  const AlreadyHaveAccountLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppLocalizations.of(context)?.alreadyHaveAccount ?? 'Đã có tài khoản? ',
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.grey600,
              ),
            ),
            TextSpan(
              text: AppLocalizations.of(context)?.loginLink ?? 'Đăng nhập',
              style: AppStyles.linkText.copyWith(
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
