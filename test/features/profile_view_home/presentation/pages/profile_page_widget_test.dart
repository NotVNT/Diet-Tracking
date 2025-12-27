import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


import '../../mocks.mocks.dart';

Widget _wrap(Widget child) {
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
      home: child,
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

  setUpAll(() async {
    // Avoid MissingPluginException for google_fonts (path_provider) when running widget tests.
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

    // Prevent SharedPreferences plugin issues in tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ProfilePage widget tests', () {
    late MockProfileRepository repository;

    setUp(() {
      repository = MockProfileRepository();
    });

    testWidgets('shows loading then renders profile name/email', (tester) async {
      final profile = ProfileEntity(uid: 'u1', displayName: 'Alice', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.isUserLoggedIn()).thenReturn(true);

      final provider = _buildProvider(repository);

      await tester.pumpWidget(_wrap(ProfilePage(profileProvider: provider)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('a@b.com'), findsOneWidget);
    });

    testWidgets('tapping Edit profile navigates to EditProfilePage', (tester) async {
      final profile = ProfileEntity(uid: 'u1', displayName: 'Alice', email: 'a@b.com', age: 22);
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.isUserLoggedIn()).thenReturn(true);

      final provider = _buildProvider(repository);

      await tester.pumpWidget(_wrap(ProfilePage(profileProvider: provider)));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;
      await tester.tap(find.text(l10n.profileEditProfile));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);
    });

    testWidgets('EditProfilePage validation prevents save when name empty', (tester) async {
      final profile = ProfileEntity(uid: 'u1', displayName: 'Alice', email: 'a@b.com', age: 22);
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.isUserLoggedIn()).thenReturn(true);
      when(repository.updateUserProfile(any)).thenAnswer((_) async {});

      final provider = _buildProvider(repository);

      await tester.pumpWidget(_wrap(ProfilePage(profileProvider: provider)));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;
      await tester.tap(find.text(l10n.profileEditProfile));
      await tester.pumpAndSettle();

      expect(find.byType(EditProfilePage), findsOneWidget);

      // Clear full name field (first TextFormField).
      await tester.enterText(find.byType(TextFormField).first, '');
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.editProfileSave));
      await tester.pumpAndSettle();

      expect(find.text(l10n.editProfilePleaseEnterFullName), findsOneWidget);
      verifyNever(repository.updateUserProfile(any));
    });

    testWidgets('tapping Sign out navigates to WelcomeScreen', (tester) async {
      final profile = ProfileEntity(uid: 'u1', displayName: 'Alice', email: 'a@b.com');
      when(repository.getUserProfile()).thenAnswer((_) async => profile);
      when(repository.isUserLoggedIn()).thenReturn(true);
      when(repository.clearLocalData()).thenAnswer((_) async {});
      when(repository.signOut()).thenAnswer((_) async {});

      final provider = _buildProvider(repository);

      await tester.pumpWidget(
        _wrap(
          ProfilePage(
            profileProvider: provider,
            welcomeScreenBuilder: (_) => const Scaffold(
              body: Center(child: Text('WELCOME_STUB')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(tester.element(find.byType(ProfilePage)))!;

      final signOut = find.text(l10n.profileSignOut);
      await tester.scrollUntilVisible(
        signOut,
        250,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(signOut);
      await tester.pumpAndSettle();

      expect(find.text('WELCOME_STUB'), findsOneWidget);

      verifyInOrder([
        repository.clearLocalData(),
        repository.signOut(),
      ]);
    });
  });
}
