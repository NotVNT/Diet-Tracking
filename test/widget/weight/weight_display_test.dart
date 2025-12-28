import 'package:diet_tracking_project/widget/weight/weight_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('renders value and unit texts', (tester) async {
    await tester.pumpWidget(
      wrap(const WeightDisplay(valueText: '130.5', unit: 'lb')),
    );

    expect(find.text('130.5'), findsOneWidget);
    expect(find.text('lb'), findsOneWidget);
  });

  testWidgets('applies correct text styles', (tester) async {
    await tester.pumpWidget(
      wrap(const WeightDisplay(valueText: '72.0', unit: 'kg')),
    );

    // Verify value text style
    final valueText = tester.widget<Text>(find.text('72.0'));
    final TextStyle? valueStyle = valueText.style;
    expect(valueStyle, isNotNull);
    expect(valueStyle!.fontSize, 56);
    expect(valueStyle.fontWeight, FontWeight.w800);
    expect(valueStyle.color, const Color(0xFF111827));
    expect(valueStyle.height, 1.0);

    // Verify unit text style
    final unitText = tester.widget<Text>(find.text('kg'));
    final TextStyle? unitStyle = unitText.style;
    expect(unitStyle, isNotNull);
    expect(unitStyle!.fontSize, 14);
    expect(unitStyle.fontWeight, FontWeight.w600);
    expect(unitStyle.color, const Color(0xFF6B7280));
  });
}
