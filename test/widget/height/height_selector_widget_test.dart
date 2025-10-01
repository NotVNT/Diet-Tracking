import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/widget/height/height_selector_widget.dart';
import 'package:diet_tracking_project/utils/height_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget _wrap(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  testWidgets('Initial CM display is correct and callbacks not called yet', (
    tester,
  ) async {
    double? lastHeight;
    bool? lastIsCm;

    await tester.pumpWidget(
      _wrap(
        HeightSelectorWidget(
          initialHeight: 172.0,
          onHeightChanged: (h) => lastHeight = h,
          onUnitChanged: (isCm) => lastIsCm = isCm,
        ),
      ),
    );

    // Should display combined rich text "172.0 cm"
    expect(find.text('172.0 cm'), findsOneWidget);

    // No callbacks fired on build
    expect(lastHeight, isNull);
    expect(lastIsCm, isNull);
  });

  testWidgets(
    'Toggle to FT shows formatted feet-inches and onUnitChanged fires',
    (tester) async {
      bool? lastIsCm;

      await tester.pumpWidget(
        _wrap(
          HeightSelectorWidget(
            initialHeight: 172.0,
            onHeightChanged: (_) {},
            onUnitChanged: (isCm) => lastIsCm = isCm,
          ),
        ),
      );

      // Tap FT button (second toggle half)
      final ftToggle = find.text('FT');
      expect(ftToggle, findsOneWidget);
      await tester.tap(ftToggle);
      await tester.pumpAndSettle();

      // Verify formatted text like 5'8" (depends on conversion)
      final formatted = formatHeight(172.0, false);
      expect(find.text(formatted), findsOneWidget);

      // onUnitChanged should report false (now in FT)
      expect(lastIsCm, isFalse);
    },
  );

  testWidgets(
    'Typing into CM TextField updates value and triggers onHeightChanged',
    (tester) async {
      double? lastHeight;

      await tester.pumpWidget(
        _wrap(
          HeightSelectorWidget(
            initialHeight: 172.0,
            onHeightChanged: (h) => lastHeight = h,
            onUnitChanged: (_) {},
          ),
        ),
      );

      // Find CM TextField (visible by default)
      final cmField = find.byType(TextField).first;
      await tester.enterText(cmField, '180.5');
      await tester.pumpAndSettle();

      // Due to wheel sync rounding, final selected value rounds to 181.0
      expect(lastHeight, 181.0);
      expect(find.text('181.0 cm'), findsOneWidget);
    },
  );

  testWidgets(
    'Typing into FT/in fields updates value and triggers onHeightChanged',
    (tester) async {
      double? lastHeight;

      await tester.pumpWidget(
        _wrap(
          HeightSelectorWidget(
            initialHeight: 172.0,
            onHeightChanged: (h) => lastHeight = h,
            onUnitChanged: (_) {},
          ),
        ),
      );

      // Switch to FT
      await tester.tap(find.text('FT'));
      await tester.pumpAndSettle();

      // Find two TextFields for feet and inches (there are exactly 2 visible)
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(2));

      // Enter 5 feet and 10 inches -> ~177.8 cm (clamped within range)
      await tester.enterText(fields.at(0), '5');
      await tester.enterText(fields.at(1), '10');
      await tester.pumpAndSettle();

      // Verify callback received a value close to conversion
      final expected = feetInchesToCm(5, 10);
      expect(lastHeight, closeTo(expected, 0.5));
    },
  );
}
