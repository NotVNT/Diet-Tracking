import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/started_screen.dart';
import 'package:diet_tracking_project/common/language_selector.dart';

void main() {
  group('StartScreen', () {
    testWidgets('Render tiêu đề và LanguageSelector', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: StartScreen()));

      expect(find.text('Xác định mục tiêu của bạn'), findsOneWidget);
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.text('Bắt đầu ngay!'), findsOneWidget);
    });

    testWidgets('Tap "Bắt đầu ngay!" điều hướng tới GoalSelection', (
      tester,
    ) async {
      // Dùng widget giả để tránh khởi tạo Firebase trong GoalSelection thật
      const dummyKey = ValueKey('dummy-goal');
      final dummyGoal = Builder(
        builder: (_) => const Scaffold(body: SizedBox(key: dummyKey)),
      );
      await tester.pumpWidget(
        MaterialApp(home: StartScreen(goalSelectionBuilder: (_) => dummyGoal)),
      );

      await tester.tap(find.text('Bắt đầu ngay!'));
      await tester.pumpAndSettle();

      expect(find.byKey(dummyKey), findsOneWidget);
    });
  });
}
