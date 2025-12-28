import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/profile_view_home/domain/entities/profile_entity.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/get_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/sign_out_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/update_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/upload_avatar_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  group('profile_view_home domain usecases', () {
    late MockProfileRepository repository;

    setUp(() {
      repository = MockProfileRepository();
    });

    test('GetUserProfileUseCase.call returns repository result', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'n', email: 'e');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);

      final useCase = GetUserProfileUseCase(repository);

      final result = await useCase();

      expect(result, same(profile));
      verify(repository.getUserProfile()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('GetUserProfileUseCase.isUserLoggedIn delegates to repository', () {
      when(repository.isUserLoggedIn()).thenReturn(true);

      final useCase = GetUserProfileUseCase(repository);

      expect(useCase.isUserLoggedIn(), true);
      verify(repository.isUserLoggedIn()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('UpdateUserProfileUseCase.call updates repository', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'n', email: 'e');
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      final useCase = UpdateUserProfileUseCase(repository);

      await useCase(profile);

      verify(repository.updateUserProfile(profile)).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('UploadAvatarUseCase.call uploads via repository and returns url', () async {
      final file = File('dummy_avatar.jpg');
      when(repository.uploadAvatar(any, any)).thenAnswer((_) async => 'https://img');

      final useCase = UploadAvatarUseCase(repository);

      final result = await useCase(file, 'u1');

      expect(result, 'https://img');
      verify(repository.uploadAvatar(file, 'u1')).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('SignOutUseCase.call clears local data then signs out (order)', () async {
      when(repository.clearLocalData()).thenAnswer((_) async {});
      when(repository.signOut()).thenAnswer((_) async {});

      final useCase = SignOutUseCase(repository);

      await useCase();

      verifyInOrder([
        repository.clearLocalData(),
        repository.signOut(),
      ]);
      verifyNoMoreInteractions(repository);
    });

    test('SignOutUseCase.call does not sign out if clearLocalData throws', () async {
      when(repository.clearLocalData()).thenThrow(Exception('fail'));

      final useCase = SignOutUseCase(repository);

      await expectLater(useCase(), throwsA(isA<Exception>()));

      verify(repository.clearLocalData()).called(1);
      verifyNever(repository.signOut());
    });
  });
}
