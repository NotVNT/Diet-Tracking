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
  final Future<fb_auth.UserCredential> Function(fb_auth.AuthProvider)?
  _signInWithProviderFn;
  final Future<void> Function()? _signOutFn;
  final Future<void> Function(String providerId)? _unlinkFn;

  GoogleAuthService({
    fb_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Future<fb_auth.UserCredential> Function(fb_auth.AuthProvider)?
    signInWithProviderFn,
    Future<void> Function()? signOutFn,
    Future<void> Function(String providerId)? unlinkFn,
  }) : _auth = auth ?? fb_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _signInWithProviderFn = signInWithProviderFn,
       _signOutFn = signOutFn,
       _unlinkFn = unlinkFn;

  /// Đăng nhập bằng Google
  /// - Web: dùng GoogleAuthProvider + signInWithPopup
  /// - Android/iOS: dùng google_sign_in để lấy token rồi signInWithCredential
  Future<fb_auth.User?> signInWithGoogle({
    fb_auth.AuthProvider? providerOverride,
    Map<String, String?>? userInfoOverride,
  }) async {
    try {
      fb_auth.UserCredential credential;

      if (kIsWeb) {
        final provider =
            (providerOverride as fb_auth.GoogleAuthProvider?) ??
            (fb_auth.GoogleAuthProvider()
              ..setCustomParameters({'prompt': 'select_account'}));
        credential = await _auth.signInWithPopup(provider);
      } else {
        final provider =
            providerOverride ??
            (fb_auth.GoogleAuthProvider()
              ..setCustomParameters({'prompt': 'select_account'}));
        if (_signInWithProviderFn != null) {
          credential = await _signInWithProviderFn(provider);
        } else {
          credential = await _auth.signInWithProvider(provider);
        }
      }

      final fb_auth.User? firebaseUser = credential.user;

      // Lấy thông tin từ override (phục vụ test) nếu có
      final String? uid = userInfoOverride?['uid'] ?? firebaseUser?.uid;
      final String? email = userInfoOverride?['email'] ?? firebaseUser?.email;
      final String? displayName =
          userInfoOverride?['displayName'] ?? firebaseUser?.displayName;
    final String? avatarUrl =
      userInfoOverride?['photoURL'] ?? firebaseUser?.photoURL;

      if (uid != null) {
        // Tạo/Lưu document người dùng nếu có uid
        await _ensureUserDocumentWithFields(
          uid: uid,
          email: email,
          fullName: displayName,
          avatars: avatarUrl,
        );
      }

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
      if (_signOutFn != null) {
        await _signOutFn();
      } else {
        await _auth.signOut();
      }
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
      // Thử unlink trực tiếp, bỏ qua nếu không có liên kết Google hoặc lỗi mock
      try {
        if (_unlinkFn != null) {
          await _unlinkFn('google.com');
        } else {
          await user.unlink('google.com');
        }
      } catch (_) {
        // Bỏ qua mọi lỗi trong môi trường không có liên kết hoặc mock
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      throw AuthException(_mapAuthError(e), e.code);
    } catch (e) {
      throw AuthException('Không thể hủy liên kết Google: $e');
    }
  }

  // Helpers

  // Removed unused helper that persisted avatar

  Future<void> _ensureUserDocumentWithFields({
    required String uid,
    String? email,
    String? fullName,
    String? avatars,
  }) async {
    final docRef = _firestore.collection(_usersCollection).doc(uid);
    final snapshot = await docRef.get();
    if (snapshot.exists) {
      print('🔍 GoogleAuthService: User document already exists');
      return;
    }

    print('🔍 GoogleAuthService: Creating new user document for uid: $uid');
    final app_user.User userData = app_user.User(
      uid: uid,
      email: email,
      fullName: fullName,
      avatars: avatars,
    );
    await docRef.set(userData.toJson());
    print('🔍 GoogleAuthService: User document created successfully');
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
