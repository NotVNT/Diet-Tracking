import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/goal_selection_screen.dart';
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

  testWidgets('GoalSelection: hiển thị câu hỏi và danh sách mục tiêu', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp(GoalSelection(authService: _AuthStub())));

    expect(find.text('What is your main goal?'), findsOneWidget);
    expect(find.text('Lose weight'), findsOneWidget);
    expect(find.text('Gain weight'), findsOneWidget);
    expect(find.text('Maintain weight'), findsOneWidget);
    expect(find.text('Build muscle'), findsOneWidget);

    // Nút Next disabled khi chưa chọn
    final nextButton = find.text('Next');
    expect(nextButton, findsOneWidget);
    final elevated = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(elevated.onPressed, isNull);
  });

  testWidgets(
    'GoalSelection: chọn mục tiêu sẽ bật nút Next (không điều hướng)',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(GoalSelection(authService: _AuthStub())),
      );

      // Chọn mục tiêu "Lose weight"
      await tester.tap(find.text('Lose weight').first);
      await tester.pump();

      // Nút Next đã bật (tránh tap để không điều hướng sang màn dùng Firebase)
      final elevated = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton).last,
      );
      expect(elevated.onPressed, isNotNull);
    },
  );
}
