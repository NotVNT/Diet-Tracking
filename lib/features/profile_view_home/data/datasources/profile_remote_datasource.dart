import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../database/auth_service.dart';
import '../../../../model/user.dart';

/// Remote data source for profile operations (Firebase)
class ProfileRemoteDataSource {
  final AuthService _authService;
  final FirebaseStorage _storage;

  ProfileRemoteDataSource({
    AuthService? authService,
    FirebaseStorage? storage,
  })  : _authService = authService ?? AuthService(),
        _storage = storage ?? FirebaseStorage.instance;

  /// Get current Firebase user
  fb_auth.User? getCurrentUser() {
    return _authService.currentUser;
  }

  /// Get user data from Firestore
  Future<User?> getUserData(String uid) async {
    return await _authService.getUserData(uid);
  }

  /// Upload avatar to Firebase Storage
  Future<String> uploadAvatar(File imageFile, String userId) async {
    final String path = 'avatars/$userId.jpg';
    final Reference ref = _storage.ref().child(path);
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  /// Update user data in Firestore
  Future<void> updateUserData(String uid, User user) async {
    return await _authService.updateUserData(uid, user.toJson());
  }

  /// Sign out user
  Future<void> signOut() async {
    return await _authService.signOut();
  }
}
