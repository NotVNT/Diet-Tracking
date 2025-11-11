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
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  final AuthService? authService;
  final GuestSyncService? guestSyncService;
  final Map<String, dynamic>? preSelectedData;
  const SignupScreen({
    super.key,
    this.authService,
    this.guestSyncService,
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

  late final AuthService _authService;
  late final GuestSyncService _guestSync;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFullNameFocused = false;
  bool _isPhoneFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;
  bool _isTermsAccepted = false;

  // Dữ liệu từ on_boarding
  Map<String, dynamic> _onboardingData = {};

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _guestSync = widget.guestSyncService ?? GuestSyncService();

    // Lấy dữ liệu từ on_boarding
    _onboardingData = widget.preSelectedData ?? {};
    print('🔍 Onboarding data received: $_onboardingData');
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
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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

  /// Xử lý đăng ký user
  Future<void> _handleSignup() async {
    // Validation
    if (!_validateInputs()) {
      return;
    }

    // Test kết nối Firebase trước
    print('🔍 Testing Firebase connection...');
    final connectionOk = await _authService.testFirebaseConnection();
    if (!connectionOk) {
      _showErrorSnackBar(
        'Không thể kết nối Firebase. Vui lòng kiểm tra kết nối mạng.',
      );
      return;
    }

    // Hiển thị loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Kiểm tra email đã tồn tại chưa
      final isEmailInUse = await _authService.isEmailAlreadyInUse(
        _emailController.text.trim(),
      );

      if (isEmailInUse) {
        Navigator.of(context).pop(); // Đóng loading dialog
        _showErrorSnackBar(
          'Email này đã được sử dụng. Vui lòng chọn email khác.',
        );
        return;
      }

      // Thực hiện đăng ký với dữ liệu on_boarding
      print('🔍 Processing onboarding data: $_onboardingData');
      final user = await _authService.signUpWithOnboardingData(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _onboardingData['gender'] as String?,
        heightCm: _onboardingData['heightCm'] != null
            ? (_onboardingData['heightCm'] as num).toDouble()
            : null,
        weightKg: _onboardingData['weightKg'] != null
            ? (_onboardingData['weightKg'] as num).toDouble()
            : null,
        goalWeightKg: _onboardingData['goalWeightKg'] != null
            ? (_onboardingData['goalWeightKg'] as num).toDouble()
            : null,
        age: _onboardingData['age'] as int?,
        goal: _onboardingData['goal'] as String?,
        medicalConditions:
            _onboardingData['medicalConditions'] as List<String>?,
        allergies: _onboardingData['allergies'] as List<String>?,
      );

      if (user != null) {
        Navigator.of(context).pop(); // Đóng loading dialog

        // Gửi email xác thực
        await _authService.sendEmailVerification();

        // Đồng bộ dữ liệu khách vào hồ sơ user mới
        try {
          await _guestSync.syncGuestToUser(user.uid);
        } catch (_) {}

        _showSuccessSnackBar(
          'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
        );

        // Chuyển về màn hình đăng nhập
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.of(context).pop(); // Đóng loading dialog
        _showErrorSnackBar('Đăng ký thất bại. Vui lòng thử lại.');
      }
    } catch (e) {
      Navigator.of(context).pop(); // Đóng loading dialog
      print('❌ Exception in signup: $e');
      _showErrorSnackBar('Đăng ký thất bại. Vui lòng kiểm tra lại thông tin và thử lại.');
    }
  }

  /// Validation các trường input
  bool _validateInputs() {
    if (_fullNameController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập họ và tên.');
      return false;
    }

    if (_phoneController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập số điện thoại.');
      return false;
    }

    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Vui lòng nhập email.');
      return false;
    }

    // Kiểm tra format email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showErrorSnackBar('Email không hợp lệ.');
      return false;
    }

    if (_passwordController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập mật khẩu.');
      return false;
    }

    if (_passwordController.text.length < 6) {
      _showErrorSnackBar('Mật khẩu phải có ít nhất 6 ký tự.');
      return false;
    }

    if (_confirmPasswordController.text.isEmpty) {
      _showErrorSnackBar('Vui lòng nhập lại mật khẩu.');
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Mật khẩu xác nhận không khớp.');
      return false;
    }

    if (!_isTermsAccepted) {
      _showErrorSnackBar('Vui lòng đồng ý với điều khoản sử dụng.');
      return false;
    }

    return true;
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
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Text('Tạo tài khoản', style: AppStyles.heading1),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Họ và tên
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Họ và tên',
                        hint: 'Nhập họ và tên của bạn',
                        controller: _fullNameController,
                        isFocused: _isFullNameFocused,
                        onTap: () {
                          setState(() {
                            _isFullNameFocused = true;
                            _isPhoneFocused = false;
                            _isEmailFocused = false;
                            _isPasswordFocused = false;
                            _isConfirmPasswordFocused = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Số điện thoại
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Số điện thoại',
                        hint: 'Nhập số điện thoại',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        isFocused: _isPhoneFocused,
                        onTap: () {
                          setState(() {
                            _isPhoneFocused = true;
                            _isFullNameFocused = false;
                            _isEmailFocused = false;
                            _isPasswordFocused = false;
                            _isConfirmPasswordFocused = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Email
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Email',
                        hint: 'example@gmail.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        isFocused: _isEmailFocused,
                        onTap: () {
                          setState(() {
                            _isEmailFocused = true;
                            _isFullNameFocused = false;
                            _isPhoneFocused = false;
                            _isPasswordFocused = false;
                            _isConfirmPasswordFocused = false;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mật khẩu
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
                            _isFullNameFocused = false;
                            _isPhoneFocused = false;
                            _isEmailFocused = false;
                            _isConfirmPasswordFocused = false;
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
                  const SizedBox(height: 24),

                  // Nhập lại mật khẩu
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomInputField(
                        label: 'Nhập lại mật khẩu',
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        obscureText: !_isConfirmPasswordVisible,
                        isFocused: _isConfirmPasswordFocused,
                        onTap: () {
                          setState(() {
                            _isConfirmPasswordFocused = true;
                            _isFullNameFocused = false;
                            _isPhoneFocused = false;
                            _isEmailFocused = false;
                            _isPasswordFocused = false;
                          });
                        },
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.grey600,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Điều khoản
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isTermsAccepted = !_isTermsAccepted;
                              });
                            },
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _isTermsAccepted
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: _isTermsAccepted
                                      ? AppColors.primary
                                      : AppColors.grey400,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: _isTermsAccepted
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
                                    text: 'Tôi đồng ý với ',
                                    style: AppStyles.bodyMedium.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Điều khoản sử dụng',
                                    style: AppStyles.linkText.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                  TextSpan(
                                    text: ' và ',
                                    style: AppStyles.bodyMedium.copyWith(
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Chính sách bảo mật',
                                    style: AppStyles.linkText.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {},
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nút Đăng ký
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: CustomButton(
                        text: 'Đăng ký',
                        onPressed: _isTermsAccepted ? _handleSignup : null,
                        isEnabled: _isTermsAccepted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Link đăng nhập
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Đã có tài khoản? ',
                                style: AppStyles.bodyMedium.copyWith(
                                  color: AppColors.grey600,
                                ),
                              ),
                              TextSpan(
                                text: 'Đăng nhập',
                                style: AppStyles.linkText.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                              ),
                            ],
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
