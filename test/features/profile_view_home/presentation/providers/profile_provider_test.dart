import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/profile_view_home/domain/entities/profile_entity.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/get_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/sign_out_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/update_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/upload_avatar_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/providers/profile_provider.dart';
import 'package:diet_tracking_project/model/user.dart';

import '../../mocks.mocks.dart';

void main() {
  group('ProfileProvider', () {
    late MockProfileRepository repository;
    late ProfileProvider provider;

    setUp(() {
      repository = MockProfileRepository();

      provider = ProfileProvider(
        getUserProfileUseCase: GetUserProfileUseCase(repository),
        uploadAvatarUseCase: UploadAvatarUseCase(repository),
        signOutUseCase: SignOutUseCase(repository),
        updateUserProfileUseCase: UpdateUserProfileUseCase(repository),
      );
    });

    test('isLoggedIn delegates to GetUserProfileUseCase/repository', () {
      when(repository.isUserLoggedIn()).thenReturn(true);
      expect(provider.isLoggedIn, true);
      verify(repository.isUserLoggedIn()).called(1);
    });

    test('loadProfile success sets profile and clears loading/error', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'Name', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);

      var notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.loadProfile();

      expect(provider.profile, same(profile));
      expect(provider.isLoading, false);
      expect(provider.error, isNull);
      expect(notifyCount, greaterThanOrEqualTo(2));

      verify(repository.getUserProfile()).called(1);
    });

    test('loadProfile failure sets error and stops loading (no throw)', () async {
      when(repository.getUserProfile()).thenThrow(Exception('boom'));

      await provider.loadProfile();

      expect(provider.profile, isNull);
      expect(provider.isLoading, false);
      expect(provider.error, contains('Không thể tải hồ sơ'));

      verify(repository.getUserProfile()).called(1);
    });

    test('uploadAvatar when profile is null sets error and does not call repository', () async {
      await provider.uploadAvatar(File('dummy.jpg'));

      expect(provider.error, 'Không có hồ sơ người dùng');
      verifyNever(repository.uploadAvatar(any, any));
    });

    test('uploadAvatar success updates profile avatars and clears error', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'Name', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.uploadAvatar(any, any)).thenAnswer((_) async => 'https://new');

      await provider.loadProfile();
      await provider.uploadAvatar(File('dummy.jpg'));

      expect(provider.profile, isNotNull);
      expect(provider.profile!.avatars, 'https://new');
      expect(provider.error, isNull);

      verify(repository.uploadAvatar(any, 'u1')).called(1);
    });

    test('uploadAvatar failure sets error and rethrows', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'Name', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.uploadAvatar(any, any)).thenThrow(Exception('fail'));

      await provider.loadProfile();

      await expectLater(
        provider.uploadAvatar(File('dummy.jpg')),
        throwsA(isA<Exception>()),
      );

      expect(provider.error, contains('Không thể cập nhật ảnh'));
      verify(repository.uploadAvatar(any, 'u1')).called(1);
    });

    test('updateProfile success calls repository and updates local profile', () async {
      const updated = ProfileEntity(uid: 'u1', displayName: 'New', email: 'a@b.com');
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      await provider.updateProfile(updated);

      expect(provider.profile, same(updated));
      expect(provider.isLoading, false);
      expect(provider.error, isNull);

      verify(repository.updateUserProfile(updated)).called(1);
    });

    test('updateProfile failure sets error, stops loading, and rethrows', () async {
      const updated = ProfileEntity(uid: 'u1', displayName: 'New', email: 'a@b.com');
      when(repository.updateUserProfile(any)).thenThrow(Exception('nope'));

      await expectLater(provider.updateProfile(updated), throwsA(isA<Exception>()));

      expect(provider.isLoading, false);
      expect(provider.error, contains('Không thể cập nhật hồ sơ'));
      verify(repository.updateUserProfile(updated)).called(1);
    });

    test('signOut success clears profile', () async {
      const profile = ProfileEntity(uid: 'u1', displayName: 'Name', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.clearLocalData()).thenAnswer((_) async {});
      when(repository.signOut()).thenAnswer((_) async {});

      await provider.loadProfile();
      expect(provider.profile, isNotNull);

      await provider.signOut();

      expect(provider.profile, isNull);
      verifyInOrder([
        repository.clearLocalData(),
        repository.signOut(),
      ]);
    });

    test('signOut failure sets error and rethrows', () async {
      when(repository.clearLocalData()).thenThrow(Exception('fail'));

      await expectLater(provider.signOut(), throwsA(isA<Exception>()));

      expect(provider.error, contains('Không thể đăng xuất'));
      verify(repository.clearLocalData()).called(1);
      verifyNever(repository.signOut());
    });

    test('getAvatarImage returns correct fallback by gender', () async {
      const female = ProfileEntity(
        uid: 'u1',
        displayName: 'Name',
        email: 'a@b.com',
        gender: GenderType.female,
      );

      const male = ProfileEntity(
        uid: 'u1',
        displayName: 'Name',
        email: 'a@b.com',
        gender: GenderType.male,
      );

      const withUrl = ProfileEntity(
        uid: 'u1',
        displayName: 'Name',
        email: 'a@b.com',
        avatars: 'https://img',
      );

      // Put state in provider by updating profile via updateProfile (avoids reaching into privates)
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      await provider.updateProfile(female);
      expect(provider.getAvatarImage(), isA<AssetImage>());

      await provider.updateProfile(male);
      expect(provider.getAvatarImage(), isA<AssetImage>());

      await provider.updateProfile(withUrl);
      expect(provider.getAvatarImage(), isA<NetworkImage>());
    });
  });
}
