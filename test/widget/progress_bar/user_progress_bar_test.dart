import 'package:diet_tracking_project/widget/progress_bar/user_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProgressBarWidget', () {
    testWidgets('Renders with correct progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProgressBarWidget(progress: 0.5)),
        ),
      );

      // You can't directly test the width of the inner container,
      // but you can verify the FractionallySizedBox widthFactor.
      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, 0.5);
    });
  });

  group('ProgressBarWithSteps', () {
    testWidgets('Renders progress and step text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressBarWithSteps(currentStep: 2, totalSteps: 5),
          ),
        ),
      );

      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, 0.4);
      expect(find.text('Bước 2/5'), findsOneWidget);
    });
  });

  group('SegmentedProgressBar', () {
    testWidgets('Renders correct number of segments', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SegmentedProgressBar(segmentCount: 5, currentSegment: 2),
          ),
        ),
      );

      // Expect 5 containers to be rendered for the segments.
      expect(find.byType(Container), findsNWidgets(5));
    });
  });

  group('GradientProgressBar', () {
    testWidgets('Renders with gradient', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GradientProgressBar(progress: 0.7)),
        ),
      );

      final box = tester.widget<FractionallySizedBox>(
        find.byType(FractionallySizedBox),
      );
      expect(box.widthFactor, 0.7);

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(FractionallySizedBox),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
