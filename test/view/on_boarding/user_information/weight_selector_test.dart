import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/weight_selector.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/goal_weight_selector.dart';
import 'package:diet_tracking_project/widget/weight/weight_ruler.dart';
import 'package:diet_tracking_project/widget/weight/weight_display.dart';
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
    // Provide a mock height for BMI calculation
    SharedPreferences.setMockInitialValues({'guest_height_cm': 175.0});
  });

  testWidgets('WeightSelector: renders correctly and navigates on tap', (
    tester,
  ) async {
    // The ruler widget requires a larger screen to avoid overflow
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildApp(WeightSelector(authService: _AuthStub())),
    );

    // Verify title and other widgets are present
    expect(find.text('Weight'), findsOneWidget);
    expect(find.text('What is your weight?'), findsOneWidget);
    expect(find.byType(WeightRuler), findsOneWidget);

    // Verify the 'Next' button is present
    expect(find.widgetWithText(ElevatedButton, 'Next'), findsOneWidget);

    // Tap the 'Next' button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify navigation to GoalWeightSelector screen
    expect(find.byType(GoalWeightSelector), findsOneWidget);
  });

  testWidgets('WeightSelector: interacts with ruler and unit toggle', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      _buildApp(WeightSelector(authService: _AuthStub())),
    );

    // Initial weight is 70.0 kg. Find within the WeightDisplay to be specific.
    expect(
      find.descendant(
        of: find.byType(WeightDisplay),
        matching: find.text('70.0'),
      ),
      findsOneWidget,
    );

    // Change to lbs
    await tester.tap(find.text('lb'));
    await tester.pump();

    // Verify weight is converted to lbs (70kg * 2.20462... = 154.3)
    expect(
      find.descendant(
        of: find.byType(WeightDisplay),
        matching: find.text('154.3'),
      ),
      findsOneWidget,
    );
  });
}
