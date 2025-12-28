import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/health_info_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/user_information/height_selector.dart';
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
    locale: const Locale('en'), // Using 'en' for predictable text
    home: home,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HealthInfoScreen: renders correctly and navigates on tap', (
    tester,
  ) async {
    await tester.pumpWidget(
      _buildApp(HealthInfoScreen(authService: _AuthStub())),
    );

    // Verify localized title is present.
    expect(
      find.text('Food Allergies'),
      findsNWidgets(2),
    ); // Title and Card Title
    expect(find.byType(TextField), findsOneWidget);
    // The button is a CustomButton, so we find it by its text.
    expect(find.text('Next'), findsOneWidget);

    // Tap the 'Next' button
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    // Verify navigation to HeightSelector
    expect(find.byType(HeightSelector), findsOneWidget);
  });

  testWidgets('HealthInfoScreen: can add and remove allergies', (tester) async {
    await tester.pumpWidget(
      _buildApp(HealthInfoScreen(authService: _AuthStub())),
    );

    // Enter an allergy
    await tester.enterText(find.byType(TextField), 'Peanuts');
    await tester.pump();

    // Tap the add button
    await tester.tap(find.text('+ Add'));
    await tester.pump();

    // Verify the allergy is added
    expect(find.text('🥜 Peanuts'), findsOneWidget);

    // Tap the remove icon on the chip
    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    // Verify the allergy is removed
    expect(find.text('🥜 Peanuts'), findsNothing);
  });
}
