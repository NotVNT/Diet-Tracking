import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../../../model/user.dart';

/// Provider for managing profile state
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateUserProfileUseCase _updateUserProfileUseCase;

  ProfileEntity? _profile;
  bool _isLoading = true;
  String? _error;

  ProfileProvider({
    required GetUserProfileUseCase getUserProfileUseCase,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required SignOutUseCase signOutUseCase,
    required UpdateUserProfileUseCase updateUserProfileUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _signOutUseCase = signOutUseCase,
        _updateUserProfileUseCase = updateUserProfileUseCase;

  ProfileEntity? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _getUserProfileUseCase.isUserLoggedIn();

  /// Load user profile
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _profile = await _getUserProfileUseCase.call();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải hồ sơ: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload avatar image
  Future<void> uploadAvatar(File imageFile) async {
    if (_profile == null) {
      _error = 'Không có hồ sơ người dùng';
      notifyListeners();
      return;
    }

    try {
      await _uploadAvatarUseCase.call(imageFile, _profile!.uid);
      // Avatar uploaded successfully - you can store URL locally if needed
      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật ảnh: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(ProfileEntity updatedProfile) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _updateUserProfileUseCase.call(updatedProfile);
      _profile = updatedProfile;
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật hồ sơ: $e';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _signOutUseCase.call();
      _profile = null;
      notifyListeners();
    } catch (e) {
      _error = 'Không thể đăng xuất: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Get default avatar asset based on gender
  String getDefaultAvatarAsset() {
    final gender = _profile?.gender;
    if (gender == GenderType.male) {
      return 'assets/gender/men.jpg';
    }
    if (gender == GenderType.female) {
      return 'assets/gender/women.jpg';
    }
    return 'assets/gender/men.jpg';
  }
}
