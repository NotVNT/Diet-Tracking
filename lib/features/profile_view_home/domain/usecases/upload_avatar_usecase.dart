import 'dart:io';
import '../repositories/profile_repository.dart';

/// Use case for uploading user avatar
class UploadAvatarUseCase {
  final ProfileRepository _repository;

  const UploadAvatarUseCase(this._repository);

  Future<String> call(File imageFile, String userId) async {
    return await _repository.uploadAvatar(imageFile, userId);
  }
}
