import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../common/app_colors.dart';
import '../../common/app_styles.dart';
import '../../common/custom_input_field.dart';
import '../../common/custom_button.dart';
import '../../common/gradient_background.dart';
import '../../services/authentication_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
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

  // Xử lý đăng ký
  Future<void> _handleSignup() async {
    // Kiểm tra form validation
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Kiểm tra mật khẩu khớp nhau
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu không khớp!')));
      return;
    }

    // Kiểm tra đã chọn ngày sinh
    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn ngày sinh!')));
      return;
    }

    try {
      final authService = AuthenticationService();

      // Hiển thị loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Đăng ký user với email và password
      await authService
          .signUp(_emailController.text, _passwordController.text, {
            'name': _fullNameController.text,
            'email': _emailController.text,
            'phone': _phoneController.text,
            'dateOfBirth': _selectedDate?.toIso8601String(),
            'createdAt': DateTime.now().toIso8601String(),
          });

      // Đóng loading indicator
      if (context.mounted) {
        Navigator.of(context).pop();

        // Đăng ký thành công, chuyển về màn hình đăng nhập
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Đóng loading indicator nếu có lỗi
      if (context.mounted) {
        Navigator.of(context).pop();
        // Hiển thị lỗi
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi đăng ký: $e')));
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF9C27B0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập họ và tên';
                            }
                            return null;
                          },
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

                    // Ngày sinh
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ngày sinh', style: AppStyles.labelMedium),
                            const SizedBox(height: AppStyles.spacingS),
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  border: Border.all(
                                    color: AppColors.grey300,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppStyles.radiusL,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.shadowLight,
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.grey500,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _selectedDate != null
                                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                          : 'Chọn ngày sinh',
                                      style: AppStyles.bodyMedium.copyWith(
                                        color: _selectedDate != null
                                            ? AppColors.black
                                            : AppColors.grey500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập email';
                            }
                            if (!RegExp(
                              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                            ).hasMatch(value)) {
                              return 'Email không hợp lệ';
                            }
                            return null;
                          },
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu';
                            }
                            if (value.length < 6) {
                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                            }
                            return null;
                          },
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
      ),
    );
  }
}
