import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:diet_tracking_project/features/profile_view_home/presentation/pages/profile_page.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/providers/profile_provider.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/get_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/upload_avatar_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/sign_out_usecase.dart';

import 'profile_view_test.mocks.dart';

@GenerateMocks([GetUserProfileUseCase, UploadAvatarUseCase, SignOutUseCase])
void main() {
  group('ProfilePage', () {
    late MockGetUserProfileUseCase mockGetUserProfileUseCase;
    late MockUploadAvatarUseCase mockUploadAvatarUseCase;
    late MockSignOutUseCase mockSignOutUseCase;
    late ProfileProvider profileProvider;

    setUp(() {
      mockGetUserProfileUseCase = MockGetUserProfileUseCase();
      mockUploadAvatarUseCase = MockUploadAvatarUseCase();
      mockSignOutUseCase = MockSignOutUseCase();
      
      profileProvider = ProfileProvider(
        getUserProfileUseCase: mockGetUserProfileUseCase,
        uploadAvatarUseCase: mockUploadAvatarUseCase,
        signOutUseCase: mockSignOutUseCase,
      );
    });

    test('ProfilePage có thể được tạo với ProfileProvider', () {
      // Arrange & Act
      final profilePage = ProfilePage(profileProvider: profileProvider);

      // Assert
      expect(profilePage, isNotNull);
      expect(profilePage.profileProvider, equals(profileProvider));
    });

    test('ProfilePage có key được set đúng', () {
      // Arrange
      const key = Key('test_key');

      // Act
      final profilePage = ProfilePage(key: key, profileProvider: profileProvider);

      // Assert
      expect(profilePage.key, equals(key));
    });

    test('ProfilePage có widget type đúng', () {
      // Arrange
      final profilePage = ProfilePage(profileProvider: profileProvider);

      // Assert
      expect(profilePage, isA<StatefulWidget>());
    });
  });
}
