import '../data/datasources/profile_remote_datasource.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/usecases/get_user_profile_usecase.dart';
import '../domain/usecases/upload_avatar_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/update_user_profile_usecase.dart';
import '../presentation/providers/profile_provider.dart';

/// Dependency injection helper for Profile feature
class ProfileDI {
  static ProfileProvider? _profileProvider;

  /// Get or create ProfileProvider singleton
  static ProfileProvider getProfileProvider() {
    _profileProvider ??= _createProfileProvider();
    return _profileProvider!;
  }

  /// Create new ProfileProvider instance
  static ProfileProvider _createProfileProvider() {
    // Create data sources
    final remoteDataSource = ProfileRemoteDataSource();
    final localDataSource = ProfileLocalDataSource();

    // Create repository
    final repository = ProfileRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Create use cases
    final getUserProfileUseCase = GetUserProfileUseCase(repository);
    final uploadAvatarUseCase = UploadAvatarUseCase(repository);
    final signOutUseCase = SignOutUseCase(repository);
    final updateUserProfileUseCase = UpdateUserProfileUseCase(repository);

    // Create provider
    return ProfileProvider(
      getUserProfileUseCase: getUserProfileUseCase,
      uploadAvatarUseCase: uploadAvatarUseCase,
      signOutUseCase: signOutUseCase,
      updateUserProfileUseCase: updateUserProfileUseCase,
    );
  }

  /// Dispose singleton instance
  static void dispose() {
    _profileProvider?.dispose();
    _profileProvider = null;
  }
}
