import '../repositories/profile_repository.dart';

/// Use case for signing out user
class SignOutUseCase {
  final ProfileRepository _repository;

  const SignOutUseCase(this._repository);

  Future<void> call() async {
    await _repository.clearLocalData();
    await _repository.signOut();
  }
}
