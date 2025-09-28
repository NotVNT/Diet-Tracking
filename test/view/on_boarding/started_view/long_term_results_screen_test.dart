import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/long_term_results_screen.dart';

void main() {
  group('LongTermResultsScreen', () {
    testWidgets('Render tiêu đề và mô tả', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LongTermResultsScreen(
            selectedMainGoals: [],
            selectedWeightReasons: [],
            selectedDietReasons: [],
          ),
        ),
      );

      expect(
        find.text('Chúng tôi mang đến cho bạn hiệu quả tốt nhất'),
        findsOneWidget,
      );
    });

    testWidgets('Tap Tiếp theo điều hướng tới StartScreen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: LongTermResultsScreen(
            selectedMainGoals: [],
            selectedWeightReasons: [],
            selectedDietReasons: [],
          ),
        ),
      );

      final nextBtn = find.widgetWithText(ElevatedButton, 'Tiếp theo');
      await tester.ensureVisible(nextBtn);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      // Màn tiếp theo là user_information StartScreen với heading sau
      expect(
        find.text('Hãy cho chúng tôi biết về bản thân bạn'),
        findsOneWidget,
      );
    });
  });
}
