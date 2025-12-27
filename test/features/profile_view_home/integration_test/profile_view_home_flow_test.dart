import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:diet_tracking_project/features/profile_view_home/domain/entities/profile_entity.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/get_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/sign_out_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/update_user_profile_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/domain/usecases/upload_avatar_usecase.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/pages/edit_profile_page.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/pages/profile_page.dart';
import 'package:diet_tracking_project/features/profile_view_home/presentation/providers/profile_provider.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

import '../mocks.mocks.dart';

Widget _wrapProfile(ProfileProvider provider) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<NotificationProvider>(
        create: (_) => NotificationProvider(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: ProfilePage(profileProvider: provider),
    ),
  );
}

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

  // google_fonts uses path_provider to cache fonts on disk. When running with
  // `flutter test` (not a fully-bootstrapped app), path_provider may not have a
  // plugin implementation, so we mock its MethodChannel.
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
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

  // Keep default behavior (runtime fetching enabled).
  GoogleFonts.config.allowRuntimeFetching = true;

  group('profile_view_home integration_test', () {
    testWidgets('opens Edit Profile and saves updated name', (tester) async {
      final repository = MockProfileRepository();

      final initial = ProfileEntity(
        uid: 'u1',
        displayName: 'Old Name',
        email: 'old@example.com',
        age: 25,
      );

      when(repository.getUserProfile()).thenAnswer((_) async => initial);
      when(repository.isUserLoggedIn()).thenReturn(true);
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      final provider = _buildProvider(repository);

      await tester.pumpWidget(_wrapProfile(provider));
      await tester.pumpAndSettle();

      expect(find.text('Old Name'), findsOneWidget);

      final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;
      await tester.tap(find.text(l10n.profileEditProfile));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);

      // Full name field is the first TextFormField in the form.
      await tester.enterText(find.byType(TextFormField).first, 'New Name');
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.editProfileSave));
      await tester.pumpAndSettle();

      // After save, we should be back on ProfilePage and see the updated name.
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.text('New Name'), findsOneWidget);

      verify(repository.updateUserProfile(any)).called(1);
    });
  });
}
