import 'package:flutter/material.dart';
import '../../../database/auth_service.dart';
import '../../../database/exceptions.dart';
import '../../../database/data_migration_service.dart';
import '../../../utils/logger.dart';

/// Error codes cho đăng ký
class RegisterErrorCode {
  static const String emptyFullName = 'empty-full-name';
  static const String emptyPhone = 'empty-phone';
  static const String emptyEmail = 'empty-email';
  static const String invalidEmail = 'invalid-email';
  static const String emptyPassword = 'empty-password';
  static const String passwordTooShort = 'password-too-short';
  static const String emptyConfirmPassword = 'empty-confirm-password';
  static const String passwordMismatch = 'password-mismatch';
  static const String termsNotAccepted = 'terms-not-accepted';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String weakPassword = 'weak-password';
  static const String registrationFailed = 'registration-failed';
}

/// Controller quản lý business logic cho màn hình đăng ký
class RegisterController {
  final AuthService? authService;
  final DataMigrationService? dataMigrationService;

  AuthService? _authService;
  DataMigrationService? _dataMigration;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Dữ liệu từ on_boarding
  Map<String, dynamic> onboardingData = {};

  RegisterController({
    this.authService,
    this.dataMigrationService,
    Map<String, dynamic>? preSelectedData,
  }) {
    onboardingData = preSelectedData ?? {};
    debugPrint('Onboarding data received: $onboardingData');
  }

  /// Khởi tạo lazy services khi cần thiết
  void _ensureServicesInitialized() {
    _authService ??= authService ?? AuthService();
    _dataMigration ??= dataMigrationService ?? DataMigrationService();
  }

  /// Validate họ và tên
  String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return RegisterErrorCode.emptyFullName;
    }
    return null;
  }

  /// Validate số điện thoại
  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return RegisterErrorCode.emptyPhone;
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return RegisterErrorCode.emptyEmail;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return RegisterErrorCode.invalidEmail;
    }

    return null;
  }

  /// Validate mật khẩu
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return RegisterErrorCode.emptyPassword;
    }

    if (value.length < 6) {
      return RegisterErrorCode.passwordTooShort;
    }

    return null;
  }

  /// Validate xác nhận mật khẩu
  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return RegisterErrorCode.emptyConfirmPassword;
    }

    if (value != passwordController.text) {
      return RegisterErrorCode.passwordMismatch;
    }

    return null;
  }

  /// Validate điều khoản
  String? validateTerms(bool isAccepted) {
    if (!isAccepted) {
      return RegisterErrorCode.termsNotAccepted;
    }
    return null;
  }

  /// Validate tất cả các trường
  String? validateAllFields(bool isTermsAccepted) {
    String? error;

    error = validateFullName(fullNameController.text);
    if (error != null) return error;

    error = validatePhone(phoneController.text);
    if (error != null) return error;

    error = validateEmail(emailController.text);
    if (error != null) return error;

    error = validatePassword(passwordController.text);
    if (error != null) return error;

    error = validateConfirmPassword(confirmPasswordController.text);
    if (error != null) return error;

    error = validateTerms(isTermsAccepted);
    if (error != null) return error;

    return null;
  }

  /// Test kết nối Firebase
  Future<bool> testFirebaseConnection() async {
    _ensureServicesInitialized();
    AppLogger.debug('Testing Firebase connection...', tag: 'RegisterController');
    return await _authService!.testFirebaseConnection();
  }

  /// Kiểm tra email đã tồn tại chưa
  Future<bool> isEmailAlreadyInUse(String email) async {
    _ensureServicesInitialized();
    return await _authService!.isEmailAlreadyInUse(email);
  }

  /// Đăng ký user với dữ liệu onboarding
  Future<RegisterResult> signUp() async {
    _ensureServicesInitialized();

    try {
      debugPrint('Processing onboarding data: $onboardingData');
      final user = await _authService!.signUpWithOnboardingData(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        gender: onboardingData['gender'] as String?,
        heightCm: onboardingData['heightCm'] != null
            ? (onboardingData['heightCm'] as num).toDouble()
            : null,
        weightKg: onboardingData['weightKg'] != null
            ? (onboardingData['weightKg'] as num).toDouble()
            : null,
        goalWeightKg: onboardingData['goalWeightKg'] != null
            ? (onboardingData['goalWeightKg'] as num).toDouble()
            : null,
        age: onboardingData['age'] as int?,
        goal: onboardingData['goal'] as String?,
        allergies: onboardingData['allergies'] as List<String>?,
      );

      if (user == null) {
        return RegisterResult.failure(RegisterErrorCode.registrationFailed);
      }

      // Gửi email xác thực
      await _authService!.sendEmailVerification();

      // Đồng bộ dữ liệu guest vào hồ sơ user mới
      await _syncGuestData(user.uid);

      return RegisterResult.success(userId: user.uid);
    } on AuthException catch (e) {
      AppLogger.error('AuthException in signup: $e', tag: 'RegisterController');
      // Map AuthException codes to RegisterErrorCode
      if (e.code == 'email-already-in-use') {
        return RegisterResult.failure(RegisterErrorCode.emailAlreadyInUse);
      } else if (e.code == 'weak-password') {
        return RegisterResult.failure(RegisterErrorCode.weakPassword);
      }
      return RegisterResult.failure(RegisterErrorCode.registrationFailed);
    } catch (e) {
      debugPrint('Exception in signup: $e');
      return RegisterResult.failure(RegisterErrorCode.registrationFailed);
    }
  }

  /// Đồng bộ dữ liệu guest sang user account
  Future<void> _syncGuestData(String userId) async {
    try {
      await _dataMigration?.syncGuestToUser(userId);
    } catch (e) {
      debugPrint('Guest sync failed: $e');
    }
  }

  /// Dọn dẹp resources
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}

/// Kết quả của quá trình đăng ký
class RegisterResult {
  final bool isSuccess;
  final String? errorCode;
  final String? userId;

  RegisterResult._({required this.isSuccess, this.errorCode, this.userId});

  factory RegisterResult.success({required String userId}) {
    return RegisterResult._(isSuccess: true, userId: userId);
  }

  factory RegisterResult.failure(String errorCode) {
    return RegisterResult._(isSuccess: false, errorCode: errorCode);
  }

  // Getter for backward compatibility
  String? get error => errorCode;
}
