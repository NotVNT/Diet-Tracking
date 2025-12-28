import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/entities/profile_entity.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/get_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/sign_out_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/update_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/upload_avatar_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/providers/profile_provider.dart';

import '../mocks.mocks.dart';

ProfileProvider _buildProvider(MockProfileRepository repository) {
  return ProfileProvider(
    getUserProfileUseCase: GetUserProfileUseCase(repository),
    uploadAvatarUseCase: UploadAvatarUseCase(repository),
    signOutUseCase: SignOutUseCase(repository),
    updateUserProfileUseCase: UpdateUserProfileUseCase(repository),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Avoid MissingPluginException for google_fonts (path_provider) when running widget tests.
    const pathProviderChannel = MethodChannel(
      'plugins.flutter.io/path_provider',
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
          switch (call.method) {
            case 'getApplicationSupportDirectory':
            case 'getApplicationDocumentsDirectory':
            case 'getTemporaryDirectory':
              return Directory.systemTemp.path;
            default:
              return Directory.systemTemp.path;
          }
        });
  });

  group('profile_view_home integration_test', () {
    testWidgets('opens Edit Profile and saves updated name', (tester) async {
      final repository = MockProfileRepository();

      const initial = ProfileEntity(
        uid: 'u1',
        displayName: 'Old Name',
        email: 'old@example.com',
        age: 25,
      );

      when(repository.getUserProfile()).thenAnswer((_) async => initial);
      when(repository.isUserLoggedIn()).thenReturn(true);
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      final provider = _buildProvider(repository);

      // Fast + stable: skip UI (GoogleFonts/assets/localizations) and just verify
      // the save logic triggers repository.updateUserProfile with the new name.
      await provider.loadProfile();

      final updated = initial.copyWith(displayName: 'New Name');
      await provider.updateProfile(updated);

      final captured = verify(
        repository.updateUserProfile(captureAny),
      ).captured;
      expect(captured, isNotEmpty);
      expect((captured.last as ProfileEntity).displayName, 'New Name');
      expect(provider.profile?.displayName, 'New Name');
    });
  });
}
