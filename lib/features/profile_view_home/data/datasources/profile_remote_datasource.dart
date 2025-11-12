import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'dart:io';
import '../../../../database/auth_service.dart';
import '../../../../model/user.dart';
import '../../../../services/cloudinary_service.dart';

/// Remote data source for profile operations (Firebase)
class ProfileRemoteDataSource {
  final AuthService _authService;
  final CloudinaryService _cloudinaryService;

  ProfileRemoteDataSource({
    AuthService? authService,
    CloudinaryService? cloudinaryService,
  })  : _authService = authService ?? AuthService(),
        _cloudinaryService =
            cloudinaryService ?? CloudinaryService.fromConfig();

  /// Get current Firebase user
  fb_auth.User? getCurrentUser() {
    return _authService.currentUser;
  }

  /// Get user data from Firestore
  Future<User?> getUserData(String uid) async {
    return await _authService.getUserData(uid);
  }

  /// Upload avatar to Cloudinary
  Future<String> uploadAvatar(File imageFile, String userId) async {
    final String url = await _cloudinaryService.uploadImage(imageFile);
    await _authService.updateUserData(userId, {'avatars': url});
    return url;
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
