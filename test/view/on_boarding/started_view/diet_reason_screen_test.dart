import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/started_view/diet_reason_screen.dart';
import 'package:diet_tracking_project/view/on_boarding/started_view/long_term_results_screen.dart';

void main() {
  group('DietReasonScreen', () {
    testWidgets('Render tiêu đề và danh sách lý do', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DietReasonScreen(
            selectedMainGoals: ['Giảm cân'],
            selectedWeightReasons: ['Cải thiện sức khỏe'],
          ),
        ),
      );

      expect(
        find.text('Điều gì đã đưa bạn đến với chúng tôi?'),
        findsOneWidget,
      );
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Chọn lý do bật nút Tiếp theo và điều hướng', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DietReasonScreen(
            selectedMainGoals: ['Giảm cân'],
            selectedWeightReasons: ['Cải thiện sức khỏe'],
          ),
        ),
      );

      final nextFinder = find.widgetWithText(ElevatedButton, 'Tiếp theo');
      ElevatedButton btn = tester.widget(nextFinder);
      expect(btn.onPressed, isNull);

      await tester.tap(find.text('Muốn xây thói quen tốt'));
      await tester.pump();

      btn = tester.widget(nextFinder);
      expect(btn.onPressed, isNotNull);

      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(find.byType(LongTermResultsScreen), findsOneWidget);
    });


  });
}
