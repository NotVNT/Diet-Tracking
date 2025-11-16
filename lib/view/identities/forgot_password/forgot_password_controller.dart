import 'package:flutter/material.dart';
import 'forgot_password_service.dart';

/// Controller quản lý business logic cho forgot password
class ForgotPasswordController {
  final ForgotPasswordService? forgotPasswordService;
  
  ForgotPasswordService? _service;
  
  final TextEditingController emailController = TextEditingController();

  ForgotPasswordController({this.forgotPasswordService});

  /// Khởi tạo service khi cần
  void _ensureServiceInitialized() {
    _service ??= forgotPasswordService ?? ForgotPasswordService();
  }

  /// Validate email
  String? validateEmail(String? email) {
    _ensureServiceInitialized();
    return _service!.validateEmail(email);
  }

  /// Gửi email reset password
  Future<PasswordResetResult> sendPasswordResetEmail() async {
    _ensureServiceInitialized();
    
    final email = emailController.text.trim();
    return await _service!.sendPasswordResetEmail(email);
  }

  /// Dọn dẹp resources
  void dispose() {
    emailController.dispose();
  }
}
