import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final ProfileRepository _repository;

  const UpdateUserProfileUseCase(this._repository);

  Future<void> call(ProfileEntity profile) async {
    return await _repository.updateUserProfile(profile);
  }
}
