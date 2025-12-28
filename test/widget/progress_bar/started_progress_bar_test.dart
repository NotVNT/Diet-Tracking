import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/widget/progress_bar/started_progress_bar.dart';

void main() {
  group('StartedProgressBar', () {
    List<Color?> segmentColors(
      WidgetTester tester, {
      required Color active,
      required Color inactive,
      double barHeight = 6,
    }) {
      final containers = tester
          .widgetList<Container>(
            find.byWidgetPredicate((w) {
              if (w is! Container) return false;
              final constraints = w.constraints;
              if (constraints is! BoxConstraints) return false;
              if (constraints.minHeight != barHeight) return false;
              if (constraints.maxHeight != barHeight) return false;
              final decoration = w.decoration;
              if (decoration is! BoxDecoration) return false;
              final color = decoration.color;
              return color == active || color == inactive;
            }),
          )
          .toList();

      return containers
          .map((c) => (c.decoration as BoxDecoration).color)
          .toList();
    }

    testWidgets('renders correct segments and active colors', (tester) async {
      const active = Colors.red;
      const inactive = Colors.grey;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StartedProgressBar(
              currentStep: 3,
              totalSteps: 5,
              activeColor: active,
              inactiveColor: inactive,
              showBack: false,
              barHeight: 6,
              segmentGap: 8,
            ),
          ),
        ),
      );

      // 5 segments.
      final colors = segmentColors(
        tester,
        active: active,
        inactive: inactive,
        barHeight: 6,
      );
      expect(colors, hasLength(5));
      expect(colors.take(3), everyElement(active));
      expect(colors.skip(3), everyElement(inactive));

      // 4 gaps between segments.
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 8),
        findsNWidgets(4),
      );

      // No back button when showBack=false.
      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('totalSteps=1 renders single bar (no gaps)', (tester) async {
      const active = Colors.green;

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StartedProgressBar(
              currentStep: 1,
              totalSteps: 1,
              activeColor: active,
              showBack: false,
              barHeight: 10,
              segmentGap: 8,
            ),
          ),
        ),
      );

      // One active segment, no inter-segment gaps.
      final colors = segmentColors(
        tester,
        active: active,
        inactive: const Color(0x00000000),
        barHeight: 10,
      );
      expect(colors, [active]);
      expect(
        find.byWidgetPredicate((w) => w is SizedBox && w.width == 8),
        findsNothing,
      );
    });

    testWidgets('back button calls onBack when provided', (tester) async {
      var called = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StartedProgressBar(
              currentStep: 1,
              totalSteps: 3,
              activeColor: Colors.blue,
              inactiveColor: Colors.blueGrey,
              onBack: () => called = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(called, isTrue);
    });

    testWidgets('back button pops by default (maybePop)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const Scaffold(
                            body: StartedProgressBar(
                              currentStep: 1,
                              totalSteps: 2,
                              activeColor: Colors.purple,
                              inactiveColor: Colors.black12,
                            ),
                          ),
                        ),
                      );
                    },
                    child: const Text('Go'),
                  ),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Go'), findsOneWidget);

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byType(StartedProgressBar), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Go'), findsOneWidget);
      expect(find.byType(StartedProgressBar), findsNothing);
    });
  });
}
