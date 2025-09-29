import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../database/exceptions.dart';
import '../model/user.dart' as app_user;

/// Service đăng nhập bằng Google cho cả mobile và web
class GoogleAuthService {
  // Constants
  static const String _usersCollection = 'users';

  // Firebase instances
  final fb_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  GoogleAuthService({fb_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? fb_auth.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Đăng nhập bằng Google
  /// - Web: dùng GoogleAuthProvider + signInWithPopup
  /// - Android/iOS: dùng google_sign_in để lấy token rồi signInWithCredential
  Future<fb_auth.User?> signInWithGoogle() async {
    try {
      fb_auth.UserCredential credential;

      if (kIsWeb) {
        final provider = fb_auth.GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        credential = await _auth.signInWithPopup(provider);
      } else {
        final provider = fb_auth.GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        credential = await _auth.signInWithProvider(provider);
      }

      final fb_auth.User? firebaseUser = credential.user;
      if (firebaseUser == null) return null;

      // Tạo document người dùng nếu chưa có
      await _ensureUserDocument(firebaseUser);
      return firebaseUser;
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    } catch (e) {
      throw AuthException('Đăng nhập Google thất bại: $e');
    }
  }

  /// Đăng xuất khỏi Firebase (và Google trên mobile)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw AuthException('Không thể đăng xuất: $e');
    }
  }

  /// Hủy liên kết Google khỏi tài khoản hiện tại (nếu cần)
  Future<void> disconnectGoogle() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      await user.reload();
      final providers = user.providerData;
      final hasGoogle = providers.any((p) => p.providerId == 'google.com');
      if (hasGoogle) {
        await user.unlink('google.com');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    } catch (e) {
      throw AuthException('Không thể hủy liên kết Google: $e');
    }
  }

  // Helpers

  Future<void> _ensureUserDocument(fb_auth.User user) async {
    final docRef = _firestore.collection(_usersCollection).doc(user.uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) return;

    final app_user.User userData = app_user.User(
      uid: user.uid,
      email: user.email,
      fullName: user.displayName,
      avatarUrl: user.photoURL,
    );

    await docRef.set(userData.toJson());
  }

  String _mapAuthError(fb_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với phương thức đăng nhập khác.';
      case 'invalid-credential':
        return 'Thông tin xác thực không hợp lệ.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy người dùng.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'invalid-verification-code':
      case 'invalid-verification-id':
        return 'Mã xác minh không hợp lệ.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }
}
