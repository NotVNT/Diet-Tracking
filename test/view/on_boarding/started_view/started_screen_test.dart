import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/started_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/goal_selection_screen.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

class _AuthStub extends AuthService {
  _AuthStub() : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());
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

  testWidgets('StartScreen hiển thị tiêu đề và mô tả, nút Get started', (tester) async {
    await tester.pumpWidget(_buildApp(const StartScreen()));

    expect(find.text('Define your goal'), findsOneWidget);
    expect(find.text("We'll build a tailored plan to keep you motivated and help you reach your goals."), findsOneWidget);
    expect(find.text('Get started!'), findsOneWidget);
  });

  testWidgets('StartScreen: bấm Get started điều hướng tới GoalSelection với stub services', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        StartScreen(
          goalSelectionBuilder: (_) => GoalSelection(
            authService: _AuthStub(),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Get started!'));
    await tester.pumpAndSettle();

    // Đã điều hướng sang GoalSelection
    expect(find.byType(GoalSelection), findsOneWidget);
    // Hiển thị tiêu đề câu hỏi
    expect(find.text('What is your main goal?'), findsOneWidget);
  });
}

