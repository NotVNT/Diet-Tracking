import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../common/app_styles.dart';
import '../../../common/custom_button.dart';
import '../../../common/gradient_background.dart';
import '../../../database/auth_service.dart';
import '../../../database/guest_sync_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../responsive/responsive.dart';
import '../../../services/google_auth_service.dart';
import '../../../features/home_page/presentation/pages/home_page.dart';
import '../../../features/home_page/di/home_di.dart';
import '../../on_boarding/started_view/started_screen.dart' as started_onboarding;
import '../forgot_password/forgot_password_screen.dart';
import '../register/register_main_screen.dart';
import 'login_controller.dart';
import 'login_ui_helper.dart';
import 'login_widgets.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final GuestSyncService? guestSyncService;
  final GoogleAuthService? googleAuthService;
  
  const LoginScreen({
    super.key,
    this.authService,
    this.guestSyncService,
    this.googleAuthService,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late LoginController _loginController;
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    
    // Khởi tạo login controller
    _loginController = LoginController(
      authService: widget.authService,
      guestSyncService: widget.guestSyncService,
      googleAuthService: widget.googleAuthService,
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
    _loginController.dispose();
    super.dispose();
  }

  /// Wrapper để thực thi action với loading dialog
  Future<T> _executeWithLoading<T>(Future<T> Function() action) async {
    LoginUIHelper.showLoadingDialog(context);
    try {
      final result = await action();
      if (!mounted) return result;
      LoginUIHelper.hideLoadingDialog(context);
      return result;
    } catch (e) {
      if (mounted) {
        LoginUIHelper.hideLoadingDialog(context);
      }
      rethrow;
    }
  }

  /// Xử lý đăng nhập email/password
  Future<void> _handleLogin() async {
    final result = await _executeWithLoading(
      () => _loginController.signInWithEmailPassword(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      LoginUIHelper.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)?.loginSuccess ?? 'Đăng nhập thành công!',
      );
      _navigateAfterLogin(result.needsOnboarding);
    } else {
      final errorMessage = result.errorCode != null
          ? _getLocalizedLoginErrorMessage(result.errorCode!)
          : AppLocalizations.of(context)?.loginFailed ?? 'Đăng nhập thất bại';
      LoginUIHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  /// Xử lý đăng nhập Google
  Future<void> _handleGoogleLogin() async {
    final result = await _executeWithLoading(
      () => _loginController.signInWithGoogle(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      LoginUIHelper.showSuccessSnackBar(
        context,
        AppLocalizations.of(context)?.googleLoginSuccess ?? 'Đăng nhập Google thành công!',
      );
      _navigateAfterLogin(result.needsOnboarding);
    } else if (result.isCancelled) {
      LoginUIHelper.showErrorSnackBar(
        context,
        AppLocalizations.of(context)?.googleLoginCancelled ?? 'Đăng nhập Google đã bị hủy.',
      );
    } else {
      final errorMessage = result.errorCode != null
          ? _getLocalizedLoginErrorMessage(result.errorCode!)
          : AppLocalizations.of(context)?.googleLoginFailed ?? 'Đăng nhập Google thất bại';
      LoginUIHelper.showErrorSnackBar(context, errorMessage);
    }
  }

  /// Lấy thông báo lỗi đã localized cho đăng nhập
  String _getLocalizedLoginErrorMessage(String errorCode) {
    final loc = AppLocalizations.of(context);
    
    switch (errorCode) {
      case LoginErrorCode.emptyEmail:
        return loc?.pleaseEnterEmail ?? 'Vui lòng nhập email';
      case LoginErrorCode.emptyPassword:
        return loc?.pleaseEnterPassword ?? 'Vui lòng nhập mật khẩu';
      case LoginErrorCode.invalidCredentials:
        return loc?.invalidCredentials ?? 'Email hoặc mật khẩu không chính xác. Vui lòng thử lại.';
      case LoginErrorCode.loginFailed:
        return loc?.loginFailed ?? 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      case LoginErrorCode.googleLoginFailed:
        return loc?.googleLoginFailed ?? 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      default:
        return loc?.loginFailed ?? 'Đăng nhập thất bại';
    }
  }

  /// Xử lý forgot password - Navigate to forgot password screen
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordScreen(),
      ),
    );
  }

  /// Điều hướng sau khi đăng nhập thành công
  void _navigateAfterLogin(bool needsOnboarding) {
    if (needsOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const started_onboarding.StartScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => HomeDI.getHomeProvider(),
            child: const HomePage(),
          ),
        ),
      );
    }
  }

  /// Xử lý khi người dùng bấm "Tôi chưa có tài khoản"
  Future<void> _handleNoAccountTap() async {
    final hasGuestData = await _loginController.hasGuestData();

    if (!mounted) return;

    if (hasGuestData) {
      await _navigateToSignupWithGuestData();
    } else {
      await _navigateToOnboarding();
    }
  }

  /// Chuyển đến trang đăng ký với dữ liệu guest
  Future<void> _navigateToSignupWithGuestData() async {
    final guestData = await _loginController.getGuestData();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SignupScreen(preSelectedData: guestData),
      ),
    );
  }

  /// Chuyển đến trang onboarding cho user mới
  Future<void> _navigateToOnboarding() async {
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const started_onboarding.StartScreen(),
      ),
    );
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
                  responsive.verticalSpace(32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text(
                        AppLocalizations.of(context)?.loginTitle ?? 'Đăng Nhập',
                        style: AppStyles.heading1.copyWith(
                          fontSize: responsive.fontSize(AppStyles.heading1.fontSize ?? 32),
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(12),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: EmailInputField(
                        controller: _loginController.emailController,
                        isFocused: _isEmailFocused,
                        onTap: () {
                          setState(() {
                            _isEmailFocused = true;
                            _isPasswordFocused = false;
                          });
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: PasswordInputField(
                        controller: _loginController.passwordController,
                        isFocused: _isPasswordFocused,
                        isPasswordVisible: _isPasswordVisible,
                        onTap: () {
                          setState(() {
                            _isPasswordFocused = true;
                            _isEmailFocused = false;
                          });
                        },
                        onToggleVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  responsive.verticalSpace(12),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ForgotPasswordButton(
                        onPressed: _handleForgotPassword,
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: AppLocalizations.of(context)?.loginButton ?? 'Đăng nhập',
                        onPressed: _handleLogin,
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: const OrDivider(),
                    ),
                  ),
                  responsive.verticalSpace(24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: AppLocalizations.of(context)?.continueWithGoogle ?? 'Tiếp tục với Google',
                        onPressed: _handleGoogleLogin,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        textColor: Theme.of(context).colorScheme.onSurface,
                        icon: Image.asset(
                          'assets/logo/google_icon.png',
                          width: responsive.iconSize(20),
                          height: responsive.iconSize(20),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  responsive.verticalSpace(32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: NoAccountButton(
                        onPressed: _handleNoAccountTap,
                      ),
                    ),
                  ),
                  responsive.verticalSpace(24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
