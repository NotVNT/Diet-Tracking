import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/widget/weight/weight_responsive_design.dart';

Future<WeightResponsive> _buildResponsive(
  WidgetTester tester, {
  required double width,
  double height = 800,
}) async {
  late WeightResponsive responsive;
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, height)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            responsive = WeightResponsive.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return responsive;
}

void main() {
  group('WeightResponsive.scale', () {
    testWidgets('returns 1.0 at base width 390', (tester) async {
      final r = await _buildResponsive(tester, width: 390);
      expect(r.scale, closeTo(1.0, 1e-9));
    });

    testWidgets('clamps to minimum 0.8 for very small widths', (tester) async {
      final r = await _buildResponsive(tester, width: 200);
      expect(r.scale, 0.8);
    });

    testWidgets('clamps to maximum 1.3 for very large widths', (tester) async {
      final r = await _buildResponsive(tester, width: 700);
      expect(r.scale, 1.3);
    });
  });

  group('WeightResponsive helpers', () {
    testWidgets('font() respects its own clamp [0.85x, 1.2x]', (tester) async {
      // At min scale (0.8), font should clamp to 0.85x base
      final rMin = await _buildResponsive(tester, width: 200); // scale -> 0.8
      const base = 20.0;
      expect(rMin.scale, 0.8);
      expect(rMin.font(base), base * 0.85);

      // At base scale (1.0), font should be unchanged
      final rBase = await _buildResponsive(tester, width: 390);
      expect(rBase.font(base), base);

      // At max scale (1.3), font should clamp to 1.2x base
      final rMax = await _buildResponsive(tester, width: 700); // scale -> 1.3
      expect(rMax.scale, 1.3);
      expect(rMax.font(base), base * 1.2);
    });

    testWidgets('space() follows scale clamp [0.8x, 1.3x]', (tester) async {
      const base = 10.0;
      final rMin = await _buildResponsive(tester, width: 200); // scale -> 0.8
      expect(rMin.space(base), base * 0.8);

      final rBase = await _buildResponsive(tester, width: 390); // scale -> 1.0
      expect(rBase.space(base), base * 1.0);

      final rMax = await _buildResponsive(tester, width: 700); // scale -> 1.3
      expect(rMax.space(base), base * 1.3);
    });

    testWidgets('radius() follows scale clamp [0.8x, 1.3x]', (tester) async {
      const base = 12.0;
      final rMin = await _buildResponsive(tester, width: 200); // scale -> 0.8
      expect(rMin.radius(base), base * 0.8);

      final rBase = await _buildResponsive(tester, width: 390); // scale -> 1.0
      expect(rBase.radius(base), base * 1.0);

      final rMax = await _buildResponsive(tester, width: 700); // scale -> 1.3
      expect(rMax.radius(base), base * 1.3);
    });
  });
}
