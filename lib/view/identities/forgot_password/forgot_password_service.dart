import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Error codes cho forgot password
class ForgotPasswordErrorCode {
  static const String emptyEmail = 'empty-email';
  static const String invalidEmail = 'invalid-email';
  static const String emailNotExist = 'email-not-exist';
  static const String accountUsesProvider = 'account-uses-provider';
  static const String userNotFound = 'user-not-found';
  static const String tooManyRequests = 'too-many-requests';
  static const String networkError = 'network-error';
  static const String unknown = 'unknown';
}

/// Service để quản lý forgot password logic
class ForgotPasswordService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  
  static const String _usersCollection = 'users';

  ForgotPasswordService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Validate email format
  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ForgotPasswordErrorCode.emptyEmail;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return ForgotPasswordErrorCode.invalidEmail;
    }

    return null;
  }

  /// Gửi email reset password với validation đầy đủ
  Future<PasswordResetResult> sendPasswordResetEmail(String email) async {
    final String sanitizedEmail = email.trim();
    
    // Validate email format
    final validationError = validateEmail(sanitizedEmail);
    if (validationError != null) {
      return PasswordResetResult.failure(validationError);
    }

    String emailForReset = sanitizedEmail;

    try {
      // Kiểm tra email tồn tại và lấy sign-in methods
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(emailForReset);

      // Nếu không tìm thấy, thử với lowercase
      if (signInMethods.isEmpty) {
        final String lowerCaseEmail = sanitizedEmail.toLowerCase();
        if (lowerCaseEmail != sanitizedEmail) {
          signInMethods =
              await _auth.fetchSignInMethodsForEmail(lowerCaseEmail);
          if (signInMethods.isNotEmpty) {
            emailForReset = lowerCaseEmail;
          }
        }

        // Kiểm tra trong Firestore
        if (signInMethods.isEmpty) {
          final bool exists = await _doesUserExistByEmail(emailForReset);
          if (!exists && lowerCaseEmail != sanitizedEmail) {
            final bool existsLower = await _doesUserExistByEmail(lowerCaseEmail);
            if (existsLower) {
              emailForReset = lowerCaseEmail;
            } else {
              return PasswordResetResult.failure(
                ForgotPasswordErrorCode.emailNotExist,
              );
            }
          } else if (!exists) {
            return PasswordResetResult.failure(
              ForgotPasswordErrorCode.emailNotExist,
            );
          }
        }
      }

      // Kiểm tra provider type
      if (signInMethods.isNotEmpty && !signInMethods.contains('password')) {
        final String providers =
            signInMethods.map(_providerDisplayName).join(', ');
        return PasswordResetResult.failure(
          ForgotPasswordErrorCode.accountUsesProvider,
          additionalInfo: providers,
        );
      }

      // Gửi email reset password
      await _auth.sendPasswordResetEmail(email: emailForReset);

      return PasswordResetResult.success(emailUsed: emailForReset);
    } on FirebaseAuthException catch (e) {
      return PasswordResetResult.failure(_handleAuthException(e));
    } catch (e) {
      print('❌ Exception in password reset: $e');
      return PasswordResetResult.failure(
        ForgotPasswordErrorCode.unknown,
      );
    }
  }

  /// Kiểm tra user tồn tại trong Firestore
  Future<bool> _doesUserExistByEmail(String email) async {
    final String lowerCaseEmail = email.trim().toLowerCase();

    // Kiểm tra với normalized email
    final QuerySnapshot<Map<String, dynamic>> normalizedSnapshot =
        await _firestore
            .collection(_usersCollection)
            .where('emailLowercase', isEqualTo: lowerCaseEmail)
            .limit(1)
            .get();

    if (normalizedSnapshot.docs.isNotEmpty) {
      return true;
    }

    // Fallback: kiểm tra với email gốc
    final QuerySnapshot<Map<String, dynamic>> legacySnapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();

    return legacySnapshot.docs.isNotEmpty;
  }

  /// Chuyển đổi provider ID thành tên hiển thị
  String _providerDisplayName(String providerId) {
    switch (providerId) {
      case 'password':
        return 'Email & Mật khẩu';
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'apple.com':
        return 'Apple';
      default:
        return providerId;
    }
  }

  /// Xử lý Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return ForgotPasswordErrorCode.invalidEmail;
      case 'user-not-found':
        return ForgotPasswordErrorCode.userNotFound;
      case 'too-many-requests':
        return ForgotPasswordErrorCode.tooManyRequests;
      case 'network-request-failed':
        return ForgotPasswordErrorCode.networkError;
      default:
        return ForgotPasswordErrorCode.unknown;
    }
  }
}

/// Kết quả của việc reset password
class PasswordResetResult {
  final bool isSuccess;
  final String? errorCode;
  final String? additionalInfo;
  final String? emailUsed;

  PasswordResetResult._({
    required this.isSuccess,
    this.errorCode,
    this.additionalInfo,
    this.emailUsed,
  });

  factory PasswordResetResult.success({String? emailUsed}) {
    return PasswordResetResult._(
      isSuccess: true,
      emailUsed: emailUsed,
    );
  }

  factory PasswordResetResult.failure(String errorCode, {String? additionalInfo}) {
    return PasswordResetResult._(
      isSuccess: false,
      errorCode: errorCode,
      additionalInfo: additionalInfo,
    );
  }
  
  // Getter for backward compatibility
  String? get error => errorCode;
}
