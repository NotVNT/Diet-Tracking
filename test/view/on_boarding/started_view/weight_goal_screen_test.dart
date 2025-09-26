import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/weight_goal_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/diet_reason_screen.dart';

void main() {
  group('WeightGoalScreen', () {
    testWidgets('Render tiêu đề phù hợp với mục tiêu', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WeightGoalScreen(selectedMainGoals: ['Giảm cân']),
        ),
      );
      expect(find.textContaining('giảm cân'), findsOneWidget);
    });

    testWidgets('Chọn lý do bật nút Tiếp theo và điều hướng', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WeightGoalScreen(selectedMainGoals: ['Giảm cân']),
        ),
      );

      // Ban đầu disabled
      final nextBtnFinder = find.widgetWithText(ElevatedButton, 'Tiếp theo');
      ElevatedButton btn = tester.widget(nextBtnFinder);
      expect(btn.onPressed, isNull);

      // Chọn item đầu tiên bằng text (đảm bảo tap vào nội dung)
      final firstText = find.textContaining('Cải thiện sức khỏe');
      await tester.tap(firstText);
      await tester.pump();

      btn = tester.widget(nextBtnFinder);
      expect(btn.onPressed, isNotNull);

      // Nhấn Tiếp theo
      await tester.tap(nextBtnFinder);
      await tester.pumpAndSettle();
      expect(find.byType(DietReasonScreen), findsOneWidget);
    });

    testWidgets('Tap Bỏ qua điều hướng tới DietReasonScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WeightGoalScreen(selectedMainGoals: ['Duy trì cân nặng']),
        ),
      );

      await tester.tap(find.text('Bỏ qua'));
      await tester.pumpAndSettle();
      expect(find.byType(DietReasonScreen), findsOneWidget);
    });
  });
}
