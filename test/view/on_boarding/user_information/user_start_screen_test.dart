import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/user_start_screen.dart'
    as ui_start;
import 'package:diet_tracking_project/view/on_boarding/user_information/gender_selector.dart';

void main() {
  group('user_information/StartScreen', () {
    testWidgets('Render heading', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ui_start.StartScreen()));
      expect(
        find.textContaining('Hãy cho chúng tôi biết về bản thân bạn'),
        findsOneWidget,
      );
    });

    testWidgets('Tap Bắt đầu điều hướng GenderSelector', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ui_start.StartScreen()));
      await tester.tap(find.text('Bắt đầu'));
      await tester.pumpAndSettle();
      expect(find.byType(GenderSelector), findsOneWidget);
    });
  });
}
