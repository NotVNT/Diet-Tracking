import 'package:flutter/material.dart';
import '../../../database/auth_service.dart';
import '../../../database/exceptions.dart';
import '../../../database/data_migration_service.dart';
import '../../../database/local_storage_service.dart';
import '../../../model/user.dart' as app_user;
import '../../../services/google_auth_service.dart';
import '../../../utils/logger.dart';

/// Error codes cho đăng nhập
class LoginErrorCode {
  static const String emptyEmail = 'empty-email';
  static const String emptyPassword = 'empty-password';
  static const String invalidCredentials = 'invalid-credentials';
  static const String loginFailed = 'login-failed';
  static const String googleLoginFailed = 'google-login-failed';
}

/// Controller quản lý business logic cho màn hình đăng nhập
class LoginController {
  final AuthService? authService;
  final DataMigrationService? dataMigrationService;
  final GoogleAuthService? googleAuthService;

  AuthService? _authService;
  DataMigrationService? _dataMigration;
  GoogleAuthService? _googleAuthService;
  LocalStorageService? _localStorage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginController({
    this.authService,
    this.dataMigrationService,
    this.googleAuthService,
  });

  /// Khởi tạo lazy services khi cần thiết
  void _ensureServicesInitialized() {
    _authService ??= authService ?? AuthService();
    _dataMigration ??= dataMigrationService ?? DataMigrationService();
  }

  /// Khởi tạo Google Auth Service khi cần
  void _ensureGoogleAuthInitialized() {
    _googleAuthService ??= googleAuthService ?? GoogleAuthService();
  }

  /// Khởi tạo Local Storage Service khi cần
  void _ensureLocalStorageInitialized() {
    _localStorage ??= LocalStorageService();
  }

  /// Xử lý exception chung cho các phương thức đăng nhập
  LoginResult _handleLoginException(dynamic e, String defaultErrorCode) {
    AppLogger.error(
      'Exception occurred during login',
      error: e,
      tag: 'LoginController',
    );
    if (e is AuthException) {
      // Map AuthException codes to LoginErrorCode
      if (e.code == 'wrong-password' ||
          e.code == 'user-not-found' ||
          e.code == 'invalid-credential') {
        return LoginResult.failure(LoginErrorCode.invalidCredentials);
      }
    }
    return LoginResult.failure(defaultErrorCode);
  }

  /// Validate email input
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LoginErrorCode.emptyEmail;
    }
    return null;
  }

  /// Validate password input
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return LoginErrorCode.emptyPassword;
    }
    return null;
  }

  /// Đăng nhập bằng email và password
  Future<LoginResult> signInWithEmailPassword() async {
    final emailError = validateEmail(emailController.text);
    if (emailError != null) {
      return LoginResult.failure(emailError);
    }

    final passwordError = validatePassword(passwordController.text);
    if (passwordError != null) {
      return LoginResult.failure(passwordError);
    }

    try {
      _ensureServicesInitialized();

      final user = await _authService!.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (user == null) {
        return LoginResult.failure(LoginErrorCode.loginFailed);
      }

      // Đồng bộ dữ liệu guest
      await _syncGuestData(user.uid);

      // Kiểm tra onboarding status
      final needsOnboarding = await _checkNeedsOnboarding(user.uid);

      return LoginResult.success(
        userId: user.uid,
        needsOnboarding: needsOnboarding,
      );
    } catch (e) {
      return _handleLoginException(e, LoginErrorCode.invalidCredentials);
    }
  }

  /// Đăng nhập bằng Google
  Future<LoginResult> signInWithGoogle() async {
    try {
      _ensureGoogleAuthInitialized();
      _ensureServicesInitialized();

      final user = await _googleAuthService!.signInWithGoogle();

      if (user == null) {
        return LoginResult.cancelled();
      }

      // Đồng bộ dữ liệu guest
      await _syncGuestData(user.uid);

      // Kiểm tra onboarding status
      final needsOnboarding = await _checkNeedsOnboarding(user.uid);

      return LoginResult.success(
        userId: user.uid,
        needsOnboarding: needsOnboarding,
      );
    } catch (e) {
      return _handleLoginException(e, LoginErrorCode.googleLoginFailed);
    }
  }

  /// Kiểm tra xem user có dữ liệu guest không
  Future<bool> hasGuestData() async {
    _ensureLocalStorageInitialized();
    return await _localStorage!.hasGuestData();
  }

  /// Kiểm tra xem guest đã hoàn tất onboarding cần thiết chưa
  Future<bool> hasCompleteGuestOnboarding() async {
    _ensureLocalStorageInitialized();
    return await _localStorage!.hasCompleteGuestOnboarding();
  }

  /// Lấy dữ liệu guest
  Future<Map<String, dynamic>?> getGuestData() async {
    _ensureLocalStorageInitialized();
    return await _localStorage!.readGuestData();
  }

  /// Đồng bộ dữ liệu guest sang user account
  Future<void> _syncGuestData(String userId) async {
    try {
      await _dataMigration?.syncGuestToUser(userId);
    } catch (e) {
      AppLogger.warning('Guest sync failed: $e', tag: 'LoginController');
    }
  }

  /// Kiểm tra xem user có cần onboarding không
  Future<bool> _checkNeedsOnboarding(String userId) async {
    final app_user.User? profile = await _authService!.getUserData(userId);

    return profile == null ||
        profile.bodyInfo?.heightCm == null ||
        profile.bodyInfo?.weightKg == null ||
        profile.gender == null ||
        profile.age == null;
  }

  /// Dọn dẹp resources
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}

/// Kết quả của quá trình đăng nhập
class LoginResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? error;
  final String? userId;
  final bool needsOnboarding;

  LoginResult._({
    required this.isSuccess,
    this.isCancelled = false,
    this.error,
    this.userId,
    this.needsOnboarding = false,
  });

  factory LoginResult.success({
    required String userId,
    required bool needsOnboarding,
  }) {
    return LoginResult._(
      isSuccess: true,
      userId: userId,
      needsOnboarding: needsOnboarding,
    );
  }

  factory LoginResult.failure(String error) {
    return LoginResult._(isSuccess: false, error: error);
  }

  factory LoginResult.cancelled() {
    return LoginResult._(isSuccess: false, isCancelled: true);
  }

  // Getter for backward compatibility - returns errorCode
  String? get errorCode => error;
}
