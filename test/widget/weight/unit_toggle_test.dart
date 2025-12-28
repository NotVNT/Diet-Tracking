import 'package:diet_tracking_project/widget/weight/unit_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  Future<BoxDecoration?> decorationForLabel(
    WidgetTester tester,
    String label,
  ) async {
    final textFinder = find.text(label);
    expect(textFinder, findsOneWidget);

    final containerFinder = find.ancestor(
      of: textFinder,
      matching: find.byType(AnimatedContainer),
    );

    final AnimatedContainer animatedContainer = tester
        .widget<AnimatedContainer>(containerFinder);
    final decoration = animatedContainer.decoration;
    return decoration is BoxDecoration ? decoration : null;
  }

  testWidgets('renders both options', (tester) async {
    bool? lastValue;
    await tester.pumpWidget(
      wrap(UnitToggle(isKg: true, onChanged: (v) => lastValue = v)),
    );

    expect(find.text('kg'), findsOneWidget);
    expect(find.text('lb'), findsOneWidget);
    expect(lastValue, isNull);
  });

  testWidgets('highlights kg when isKg=true, lb when isKg=false', (
    tester,
  ) async {
    // isKg = true
    await tester.pumpWidget(wrap(UnitToggle(isKg: true, onChanged: (_) {})));

    final kgDecoTrue = await decorationForLabel(tester, 'kg');
    final lbDecoTrue = await decorationForLabel(tester, 'lb');

    expect(kgDecoTrue?.color, equals(Colors.black));
    expect(lbDecoTrue?.color, equals(Colors.transparent));

    // isKg = false
    await tester.pumpWidget(wrap(UnitToggle(isKg: false, onChanged: (_) {})));
    await tester.pumpAndSettle();

    final kgDecoFalse = await decorationForLabel(tester, 'kg');
    final lbDecoFalse = await decorationForLabel(tester, 'lb');

    expect(kgDecoFalse?.color, equals(Colors.transparent));
    expect(lbDecoFalse?.color, equals(Colors.black));
  });

  testWidgets('tapping chips calls onChanged with correct values', (
    tester,
  ) async {
    final tappedValues = <bool>[];
    await tester.pumpWidget(
      wrap(UnitToggle(isKg: true, onChanged: tappedValues.add)),
    );

    await tester.tap(find.text('lb'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('kg'));
    await tester.pumpAndSettle();

    expect(tappedValues, equals(<bool>[false, true]));
  });
}
