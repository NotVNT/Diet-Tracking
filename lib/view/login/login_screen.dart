import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../common/app_colors.dart';
import '../../common/app_styles.dart';
import '../../common/custom_input_field.dart';
import '../../common/custom_button.dart';
import '../../common/gradient_background.dart';
import '../../database/auth_service.dart';
import '../../database/guest_sync_service.dart';
import '../../database/local_storage_service.dart';
import '../home/home_view.dart';
import '../on_boarding/started_view/started_screen.dart' as started_onboarding;
import '../../model/user.dart' as app_user;
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final AuthService? authService;
  final GuestSyncService? guestSyncService;
  const LoginScreen({super.key, this.authService, this.guestSyncService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late final AuthService _authService;
  late final GuestSyncService _guestSync;
  final LocalStorageService _localStorage = LocalStorageService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _guestSync = widget.guestSyncService ?? GuestSyncService();
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập email');
      return;
    }
    if (_passwordController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập mật khẩu');
      return;
    }

    try {
      _showLoadingDialog();

      final user = await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _hideLoadingDialog();

      if (user != null) {
        print('✅ Login successful in UI');
        _showSuccessSnackBar('Đăng nhập thành công!');

        // Đồng bộ dữ liệu khách vào user trước khi quyết định điều hướng
        try {
          await _guestSync.syncGuestToUser(user.uid);
        } catch (e) {
          print('⚠️ Guest sync failed: $e');
        }

        // Kiểm tra hồ sơ đã đủ thông tin cơ bản chưa
        final app_user.User? profile = await _authService.getUserData(user.uid);
        final bool needsOnboarding =
            profile == null ||
            (profile.goals == null || profile.goals!.isEmpty) ||
            profile.heightCm == null ||
            profile.weightKg == null ||
            profile.age == null ||
            profile.gender == null;

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
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        }
      } else {
        print('❌ Login failed in UI');
        _showErrorSnackBar(
          'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.',
        );
      }
    } catch (e) {
      print('❌ Exception in login: $e');
      _hideLoadingDialog();
      _showErrorSnackBar('Đã xảy ra lỗi không xác định: $e');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context).pop();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Xử lý khi người dùng bấm "Tôi chưa có tài khoản"
  /// Kiểm tra nếu là guest user thì chuyển thẳng đến đăng ký
  /// Ngược lại chuyển đến onboarding
  Future<void> _handleNoAccountTap() async {
    final hasGuestData = await _localStorage.hasGuestData();

    if (!mounted) return;

    if (hasGuestData) {
      await _navigateToSignupWithGuestData();
    } else {
      await _navigateToOnboarding();
    }
  }

  /// Chuyển đến trang đăng ký với dữ liệu guest
  Future<void> _navigateToSignupWithGuestData() async {
    final guestData = await _localStorage.readGuestData();

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
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text('Đăng Nhập', style: AppStyles.heading1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Email hoặc Số Điện Thoại',
                        hint: 'Nhập Email hoặc Số Điện Thoại',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
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
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Mật khẩu',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        isFocused: _isPasswordFocused,
                        onTap: () {
                          setState(() {
                            _isPasswordFocused = true;
                            _isEmailFocused = false;
                          });
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey600,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password
                          },
                          child: Text(
                            'Quên mật khẩu?',
                            style: AppStyles.linkText,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: 'Đăng nhập',
                        onPressed: _handleLogin,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.grey300,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'HOẶC đăng nhập bằng',
                              style: AppStyles.bodyMedium.copyWith(
                                color: const Color.fromARGB(255, 51, 50, 50),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: AppColors.grey300,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: 'Tiếp tục với Google',
                        onPressed: () {
                          // TODO: Handle Google login
                        },
                        backgroundColor: AppColors.white,
                        textColor: AppColors.black,
                        icon: Image.asset(
                          'assets/logo/google_icon.png',
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: TextButton(
                          onPressed: _handleNoAccountTap,
                          child: Text(
                            'Tôi chưa có tài khoản',
                            style: AppStyles.linkText.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
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
