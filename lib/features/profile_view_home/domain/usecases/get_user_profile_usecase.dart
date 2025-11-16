import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final ProfileRepository _repository;

  const GetUserProfileUseCase(this._repository);

  Future<ProfileEntity?> call() async {
    return await _repository.getUserProfile();
  }

  bool isUserLoggedIn() {
    return _repository.isUserLoggedIn();
  }
}
