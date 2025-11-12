import 'package:flutter/material.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_button.dart';
import '../../../common/gradient_background.dart';
import '../../../l10n/app_localizations.dart';
import 'forgot_password_controller.dart';
import 'forgot_password_service.dart';
import 'forgot_password_ui_helper.dart';
import 'forgot_password_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late ForgotPasswordController _controller;
  
  bool _isEmailFocused = false;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo controller
    _controller = ForgotPasswordController();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Wrapper để thực thi action với loading dialog
  Future<T> _executeWithLoading<T>(Future<T> Function() action) async {
    ForgotPasswordUIHelper.showLoadingDialog(context);
    try {
      final result = await action();
      if (!mounted) return result;
      ForgotPasswordUIHelper.hideLoadingDialog(context);
      return result;
    } catch (e) {
      if (mounted) {
        ForgotPasswordUIHelper.hideLoadingDialog(context);
      }
      rethrow;
    }
  }

  /// Xử lý gửi email reset password
  Future<void> _handleSendResetEmail() async {
    // Validate email trước
    final validationError = _controller.validateEmail(
      _controller.emailController.text,
    );

    if (validationError != null) {
      final errorMessage = _getLocalizedErrorMessage(validationError);
      ForgotPasswordUIHelper.showErrorSnackBar(context, errorMessage);
      return;
    }

    // Gửi email reset
    final result = await _executeWithLoading(
      () => _controller.sendPasswordResetEmail(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      // Hiển thị dialog thành công và quay về login
      ForgotPasswordUIHelper.showSuccessDialog(
        context,
        title: AppLocalizations.of(context)?.success ?? 'Thành công',
        message: AppLocalizations.of(context)?.passwordResetEmailSent ??
            'Đã gửi email đặt lại mật khẩu. Vui lòng kiểm tra hộp thư của bạn.',
        onOkPressed: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Back to login
        },
      );
    } else {
      final errorMessage = result.errorCode != null
          ? _getLocalizedErrorMessage(result.errorCode!, result.additionalInfo)
          : AppLocalizations.of(context)?.passwordResetFailed ??
              'Không thể gửi email đặt lại mật khẩu.';
      ForgotPasswordUIHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  /// Lấy thông báo lỗi đã localized
  String _getLocalizedErrorMessage(String errorCode, [String? additionalInfo]) {
    final loc = AppLocalizations.of(context);
    
    switch (errorCode) {
      case ForgotPasswordErrorCode.emptyEmail:
        return loc?.pleaseEnterValidEmail ?? 'Vui lòng nhập email.';
      case ForgotPasswordErrorCode.invalidEmail:
        return loc?.invalidEmail ?? 'Email không hợp lệ.';
      case ForgotPasswordErrorCode.emailNotExist:
        return loc?.emailNotExist ?? 'Email không tồn tại trong hệ thống.';
      case ForgotPasswordErrorCode.accountUsesProvider:
        final provider = additionalInfo ?? 'external provider';
        return loc?.accountUsesProviderMessage(provider) ??
            'Tài khoản này đang đăng nhập bằng: $provider. Không thể đặt lại mật khẩu bằng email.';
      case ForgotPasswordErrorCode.userNotFound:
        return loc?.userNotFound ?? 'Không tìm thấy tài khoản với email này.';
      case ForgotPasswordErrorCode.tooManyRequests:
        return loc?.tooManyRequests ?? 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case ForgotPasswordErrorCode.networkError:
        return loc?.networkError ?? 'Lỗi kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.';
      default:
        return loc?.unableToSendResetEmail ?? 'Không thể gửi email đặt lại mật khẩu. Vui lòng thử lại sau.';
    }
  }

  /// Xử lý quay lại login
  void _handleBackToLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: _handleBackToLogin,
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  
                  // Title
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        AppLocalizations.of(context)?.forgotPasswordTitle ??
                            'Quên mật khẩu?',
                        style: AppStyles.heading1.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Instruction
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: const ForgotPasswordInstruction(),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Email field
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ForgotPasswordEmailField(
                        controller: _controller.emailController,
                        isFocused: _isEmailFocused,
                        onTap: () {
                          setState(() {
                            _isEmailFocused = true;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Send button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: AppLocalizations.of(context)?.sendResetEmail ??
                            'Gửi email đặt lại mật khẩu',
                        onPressed: _handleSendResetEmail,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Back to login link
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: BackToLoginLink(
                        onTap: _handleBackToLogin,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
