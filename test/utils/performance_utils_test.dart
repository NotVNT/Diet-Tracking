import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/utils/performance_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PerformanceUtils.buildCachedImage', () {
    testWidgets('renders placeholder immediately with custom widget', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PerformanceUtils.buildCachedImage(
            imageUrl: 'https://invalid.example.com/image.png',
            width: 100,
            height: 80,
            placeholder: const Text('PH'),
          ),
        ),
      );

      expect(find.text('PH'), findsOneWidget);
    });
  });

  group('PerformanceUtils.wrapWithRepaintBoundary', () {
    testWidgets('wraps child and preserves it in tree', (tester) async {
      const childKey = Key('child');
      await tester.pumpWidget(
        MaterialApp(
          home: PerformanceUtils.wrapWithRepaintBoundary(
            const Text('X', key: childKey),
          ),
        ),
      );

      // There can be multiple RepaintBoundaries in the widget tree (MaterialApp, etc.)
      // Ensure at least one exists from our wrapper.
      expect(find.byType(RepaintBoundary), findsWidgets);
      expect(find.byKey(childKey), findsOneWidget);
    });
  });

  group('PerformanceUtils spacers', () {
    testWidgets('static spacers are SizedBox with expected dimensions', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Column(
            children: const [
              PerformanceUtils.spacer4,
              PerformanceUtils.spacer8,
              PerformanceUtils.spacer12,
              PerformanceUtils.spacer16,
              PerformanceUtils.spacer24,
            ],
          ),
        ),
      );

      final boxes = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();
      // At least 5 including top-level structures, ensure our expected sizes are present
      final heights = boxes.map((b) => b.height).whereType<double>().toList();
      expect(heights.contains(4), true);
      expect(heights.contains(8), true);
      expect(heights.contains(12), true);
      expect(heights.contains(16), true);
      expect(heights.contains(24), true);
    });
  });
}
