import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/goal_selection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/weight_goal_screen.dart';

void main() {
  group('GoalSelection', () {
    testWidgets('Render tiêu đề và danh sách mục tiêu', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          home: GoalSelection(
            localStorageService: LocalStorageService(),
            authService: AuthService(
              auth: MockFirebaseAuth(),
              firestore: FakeFirebaseFirestore(),
            ),
          ),
        ),
      );

      expect(find.text('Mục tiêu chính của bạn là gì?'), findsOneWidget);
      // Ít nhất một item hiển thị
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Chạm chọn mục tiêu bật nút Tiếp theo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          home: GoalSelection(
            localStorageService: LocalStorageService(),
            authService: AuthService(
              auth: MockFirebaseAuth(),
              firestore: FakeFirebaseFirestore(),
            ),
          ),
        ),
      );

      // Nút Tiếp theo ban đầu disabled
      final buttonFinder = find.widgetWithText(ElevatedButton, 'Tiếp theo');
      ElevatedButton btn = tester.widget(buttonFinder);
      expect(btn.onPressed, isNull);

      // Chọn mục tiêu đầu tiên theo text để đảm bảo trúng ô
      await tester.tap(find.text('Giảm cân'));
      await tester.pump();

      btn = tester.widget(buttonFinder);
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('Tap Bỏ qua điều hướng tới WeightGoalScreen', (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          home: GoalSelection(
            localStorageService: LocalStorageService(),
            authService: AuthService(
              auth: MockFirebaseAuth(),
              firestore: FakeFirebaseFirestore(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Bỏ qua'));
      await tester.pumpAndSettle();

      expect(find.byType(WeightGoalScreen), findsOneWidget);
    });
  });
}
