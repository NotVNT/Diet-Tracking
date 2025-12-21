import 'package:flutter/material.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_button.dart';
import '../../../common/gradient_background.dart';
import '../../../database/auth_service.dart';
import '../../../database/data_migration_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../responsive/responsive.dart';
import '../login/login_main_screen.dart';
import 'register_controller.dart';
import 'register_ui_helper.dart';
import 'register_widgets.dart';

class SignupScreen extends StatefulWidget {
  final AuthService? authService;
  final DataMigrationService? dataMigrationService;
  final Map<String, dynamic>? preSelectedData;
  const SignupScreen({
    super.key,
    this.authService,
    this.dataMigrationService,
    this.preSelectedData,
  });

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late RegisterController _registerController;
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFullNameFocused = false;
  bool _isPhoneFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isTermsAccepted = false;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo register controller
    _registerController = RegisterController(
      authService: widget.authService,
      dataMigrationService: widget.dataMigrationService,
      preSelectedData: widget.preSelectedData,
    );
    
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
    _registerController.dispose();
    super.dispose();
  }

  /// Wrapper để thực thi action với loading dialog
  Future<T> _executeWithLoading<T>(Future<T> Function() action) async {
    RegisterUIHelper.showLoadingDialog(context);
    try {
      final result = await action();
      if (!mounted) return result;
      RegisterUIHelper.hideLoadingDialog(context);
      return result;
    } catch (e) {
      if (mounted) {
        RegisterUIHelper.hideLoadingDialog(context);
      }
      rethrow;
    }
  }

  /// Xử lý đăng ký user
  Future<void> _handleSignup() async {
    // Validation
    final validationError = _registerController.validateAllFields(_isTermsAccepted);
    if (validationError != null) {
      final errorMessage = _getLocalizedErrorMessage(validationError);
      RegisterUIHelper.showErrorSnackBar(context, errorMessage);
      return;
    }

    // Test kết nối Firebase trước
    final connectionOk = await _registerController.testFirebaseConnection();
    if (!connectionOk) {
      if (!mounted) return;
      RegisterUIHelper.showErrorSnackBar(
        context,
        AppLocalizations.of(context)?.networkError ?? 'Không thể kết nối Firebase. Vui lòng kiểm tra kết nối mạng.',
      );
      return;
    }

    // Kiểm tra email đã tồn tại chưa
    final isEmailInUse = await _executeWithLoading(
      () => _registerController.isEmailAlreadyInUse(
        _registerController.emailController.text.trim(),
      ),
    );

    if (!mounted) return;

    if (isEmailInUse) {
      RegisterUIHelper.showErrorSnackBar(
        context,
        AppLocalizations.of(context)?.emailAlreadyInUse ?? 'Email này đã được sử dụng. Vui lòng chọn email khác.',
      );
      return;
    }

    // Thực hiện đăng ký
    final result = await _executeWithLoading(
      () => _registerController.signUp(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      RegisterUIHelper.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)?.registrationSuccess ?? 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
      );
      
      // Chuyển về màn hình đăng nhập
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      final errorMessage = result.errorCode != null
          ? _getLocalizedErrorMessage(result.errorCode!)
          : AppLocalizations.of(context)?.registrationFailed ?? 'Đăng ký thất bại. Vui lòng thử lại.';
      RegisterUIHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  /// Lấy thông báo lỗi đã localized
  String _getLocalizedErrorMessage(String errorCode) {
    final loc = AppLocalizations.of(context);
    
    switch (errorCode) {
      case RegisterErrorCode.emptyFullName:
        return loc?.pleaseEnterFullName ?? 'Vui lòng nhập họ và tên.';
      case RegisterErrorCode.emptyPhone:
        return loc?.pleaseEnterPhoneNumber ?? 'Vui lòng nhập số điện thoại.';
      case RegisterErrorCode.emptyEmail:
        return loc?.pleaseEnterEmail ?? 'Vui lòng nhập email.';
      case RegisterErrorCode.invalidEmail:
        return loc?.invalidEmail ?? 'Email không hợp lệ.';
      case RegisterErrorCode.emptyPassword:
        return loc?.pleaseEnterPassword ?? 'Vui lòng nhập mật khẩu.';
      case RegisterErrorCode.passwordTooShort:
        return loc?.passwordMinLength ?? 'Mật khẩu phải có ít nhất 6 ký tự.';
      case RegisterErrorCode.emptyConfirmPassword:
        return loc?.pleaseConfirmPassword ?? 'Vui lòng nhập lại mật khẩu.';
      case RegisterErrorCode.passwordMismatch:
        return loc?.passwordsDoNotMatch ?? 'Mật khẩu xác nhận không khớp.';
      case RegisterErrorCode.termsNotAccepted:
        return loc?.pleaseAgreeToTerms ?? 'Vui lòng đồng ý với điều khoản sử dụng.';
      case RegisterErrorCode.emailAlreadyInUse:
        return loc?.emailAlreadyInUse ?? 'Email đã được sử dụng. Vui lòng sử dụng email khác.';
      case RegisterErrorCode.weakPassword:
        return loc?.weakPassword ?? 'Mật khẩu quá yếu. Vui lòng sử dụng mật khẩu mạnh hơn.';
      case RegisterErrorCode.registrationFailed:
        return loc?.registrationFailed ?? 'Đăng ký thất bại. Vui lòng thử lại.';
      default:
        return loc?.registrationFailed ?? 'Đăng ký thất bại. Vui lòng thử lại.';
    }
  }

  /// Reset tất cả focus states
  void _resetFocusStates() {
    setState(() {
      _isFullNameFocused = false;
      _isPhoneFocused = false;
      _isEmailFocused = false;
      _isPasswordFocused = false;
      _isConfirmPasswordFocused = false;
    });
  }

  /// Set focus cho một field cụ thể
  void _setFocus(String fieldName) {
    _resetFocusStates();
    setState(() {
      switch (fieldName) {
        case 'fullName':
          _isFullNameFocused = true;
          break;
        case 'phone':
          _isPhoneFocused = true;
          break;
        case 'email':
          _isEmailFocused = true;
          break;
        case 'password':
          _isPasswordFocused = true;
          break;
        case 'confirmPassword':
          _isConfirmPasswordFocused = true;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: responsive.edgePadding(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  responsive.verticalSpace(40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        AppLocalizations.of(context)?.signupTitle ?? 'Tạo tài khoản',
                        style: AppStyles.heading1.copyWith(
                          fontSize: responsive.fontSize(AppStyles.heading1.fontSize ?? 32),
                        ),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(16),

                  // Họ và tên
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: FullNameInputField(
                        controller: _registerController.fullNameController,
                        isFocused: _isFullNameFocused,
                        onTap: () => _setFocus('fullName'),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),

                  // Số điện thoại
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PhoneInputField(
                        controller: _registerController.phoneController,
                        isFocused: _isPhoneFocused,
                        onTap: () => _setFocus('phone'),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),

                  // Email
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: EmailInputField(
                        controller: _registerController.emailController,
                        isFocused: _isEmailFocused,
                        onTap: () => _setFocus('email'),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),

                  // Mật khẩu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PasswordInputField(
                        controller: _registerController.passwordController,
                        isFocused: _isPasswordFocused,
                        isPasswordVisible: _isPasswordVisible,
                        onTap: () => _setFocus('password'),
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),

                  // Nhập lại mật khẩu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ConfirmPasswordInputField(
                        controller: _registerController.confirmPasswordController,
                        isFocused: _isConfirmPasswordFocused,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onTap: () => _setFocus('confirmPassword'),
                        onToggleVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(16),

                  // Điều khoản
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TermsCheckbox(
                        isAccepted: _isTermsAccepted,
                        onChanged: (value) {
                          setState(() {
                            _isTermsAccepted = value;
                          });
                        },
                        onTermsTap: () {
                        },
                        onPolicyTap: () {
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(32),

                  // Nút Đăng ký
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: AppLocalizations.of(context)?.signupButton ?? 'Đăng ký',
                        onPressed: _isTermsAccepted ? _handleSignup : null,
                        isEnabled: _isTermsAccepted,
                      ),
                    ),
                  ),
                  responsive.verticalSpace(40),

                  // Link đăng nhập
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: AlreadyHaveAccountLink(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
