import 'dart:io';
import '../entities/profile_entity.dart';

/// Repository interface for profile operations
abstract class ProfileRepository {
  /// Get current user profile
  Future<ProfileEntity?> getUserProfile();

  /// Check if user is logged in
  bool isUserLoggedIn();

  /// Upload avatar image and return download URL
  Future<String> uploadAvatar(File imageFile, String userId);

  /// Update user profile
  Future<void> updateUserProfile(ProfileEntity profile);

  /// Sign out current user
  Future<void> signOut();

  /// Clear all local data (food records, guest data, etc.)
  Future<void> clearLocalData();
}
