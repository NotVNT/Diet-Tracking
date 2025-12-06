import 'dart:io';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../datasources/profile_local_datasource.dart';
import '../../../../model/user.dart';
import '../../../../model/body_info_model.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required ProfileLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<ProfileEntity?> getUserProfile() async {
    final currentUser = _remoteDataSource.getCurrentUser();
    if (currentUser == null) return null;

    final userData = await _remoteDataSource.getUserData(currentUser.uid);
    if (userData == null) {
      // Return basic profile from Firebase Auth
      return ProfileEntity(
        uid: currentUser.uid,
        displayName: currentUser.displayName ?? 'Người dùng',
        email: currentUser.email ?? '',
        avatars: currentUser.photoURL,
      );
    }

    return ProfileEntity.fromUser(userData);
  }

  @override
  bool isUserLoggedIn() {
    return _remoteDataSource.getCurrentUser() != null;
  }

  @override
  Future<String> uploadAvatar(File imageFile, String userId) async {
    return await _remoteDataSource.uploadAvatar(imageFile, userId);
  }

  @override
  Future<void> updateUserProfile(ProfileEntity profile) async {
    final currentUser = _remoteDataSource.getCurrentUser();
    if (currentUser == null) {
      throw Exception('Người dùng chưa đăng nhập');
    }

    // Convert ProfileEntity to User model
    final user = User(
      uid: profile.uid,
      fullName: profile.displayName,
      email: profile.email,
      gender: profile.gender,
      age: profile.age,
      goal: profile.goal,
      avatars: profile.avatars,
      bodyInfo: BodyInfoModel(
        heightCm: profile.height,
        weightKg: profile.weight,
        goalWeightKg: profile.goalWeight,
        allergies: profile.allergies,
      ),
    );

    await _remoteDataSource.updateUserData(currentUser.uid, user);
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }

  @override
  Future<void> clearLocalData() async {
    await _localDataSource.clearAllLocalData();
  }
}
