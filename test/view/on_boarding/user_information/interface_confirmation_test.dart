import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/interface_confirmation.dart';

class _FakeLocalStorageService extends LocalStorageService {
  Map<String, dynamic> guestData = <String, dynamic>{};
  bool readGuestDataCalled = false;

  @override
  Future<Map<String, dynamic>> readGuestData() async {
    readGuestDataCalled = true;
    return guestData;
  }
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: child,
  );
}

void main() {
  group('InterfaceConfirmation', () {
    testWidgets('Render headline động', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      await tester.pumpWidget(
        _wrap(const InterfaceConfirmation(currentWeightKg: 70, goalWeightKg: 60)),
      );

      // From app_en.arb
      expect(find.text('You can do it!'), findsOneWidget);
      expect(find.textContaining('Mục tiêu:'), findsOneWidget);
    });

    testWidgets('Tap Đăng Ký Tài Khoản điều hướng SignupScreen', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      final fakeLocal = _FakeLocalStorageService()..guestData = {'gender': 'male'};

      await tester.pumpWidget(
        _wrap(
          InterfaceConfirmation(
            localStorage: fakeLocal,
            signupBuilder: (_) => const Scaffold(body: Text('SIGNUP_STUB')),
          ),
        ),
      );

      await tester.tap(find.text('Sign Up Account'));
      await tester.pumpAndSettle();

      expect(fakeLocal.readGuestDataCalled, isTrue);
      expect(find.text('SIGNUP_STUB'), findsOneWidget);
    });

    testWidgets('Tap Continue (Google) syncs and navigates HomePage', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      var syncCalled = false;

      await tester.pumpWidget(
        _wrap(
          InterfaceConfirmation(
            syncGuestOnboardingOverride: () async {
              syncCalled = true;
            },
            isGoogleSignInOverride: true,
            homeBuilder: (_) => const Scaffold(body: Text('HOME_STUB')),
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(syncCalled, isTrue);
      expect(find.text('HOME_STUB'), findsOneWidget);
    });
  });
}
