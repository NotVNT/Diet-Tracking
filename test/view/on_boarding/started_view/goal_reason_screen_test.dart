import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/goal_reason_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/diet_reason_screen.dart';
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

  testWidgets('GoalReasonScreen: hiển thị đúng câu hỏi theo goal và danh sách lý do', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        GoalReasonScreen(
          selectedMainGoals: const ['Lose weight'],
          authService: _AuthStub(),
        ),
      ),
    );

    expect(find.text('Why do you want to lose weight?'), findsOneWidget);
    // Một vài lý do phổ biến
    expect(find.text('Improve health'), findsOneWidget);
    expect(find.text('Feel more confident'), findsOneWidget);

    // Nút Next disabled khi chưa chọn
    final elevated = tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(elevated.onPressed, isNull);
  });

  testWidgets('GoalReasonScreen: chọn lý do bật Next và điều hướng DietReasonScreen', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        GoalReasonScreen(
          selectedMainGoals: const ['Lose weight'],
          authService: _AuthStub(),
        ),
      ),
    );

    // Chọn một lý do
    await tester.tap(find.text('Improve health').first);
    await tester.pump();

    // Nhấn Next
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.byType(DietReasonScreen), findsOneWidget);
  });
}

