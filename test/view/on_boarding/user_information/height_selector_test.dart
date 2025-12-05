import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/height_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';
import 'package:diet_tracking_project/widget/height/height_selector_widget.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class _AuthStub extends AuthService {
  _AuthStub()
    : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());
}

Widget _buildApp(Widget home) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: home,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HeightSelector: renders correctly and navigates on tap', (
    tester,
  ) async {
    // The next screen (WeightSelector) has a complex layout that needs more space.
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildApp(HeightSelector(authService: _AuthStub())),
    );

    // Verify title and the custom height selector widget are present
    expect(find.text('What is your height?'), findsOneWidget);
    expect(find.byType(HeightSelectorWidget), findsOneWidget);

    // Verify the 'Next' button is present
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);

    // Tap the 'Next' button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle(); // Wait for navigation animation

    // Verify navigation to WeightSelector screen
    expect(find.byType(WeightSelector), findsOneWidget);
  });
}
