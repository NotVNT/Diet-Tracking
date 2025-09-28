import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/gradient_background.dart';
import 'package:diet_tracking_project/common/app_colors.dart';

void main() {
  group('GradientBackground', () {
    group('Widget Rendering', () {
      testWidgets('should render with required child', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientBackground(child: testChild)),
          ),
        );

        expect(find.text('Test Child'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });

      testWidgets('should render with all optional parameters', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');
        const customColors = [Colors.red, Colors.blue];
        const customBegin = Alignment.topCenter;
        const customEnd = Alignment.bottomCenter;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(
                child: testChild,
                colors: customColors,
                begin: customBegin,
                end: customEnd,
              ),
            ),
          ),
        );

        expect(find.text('Test Child'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
      });
    });

    group('Default Properties', () {
      testWidgets('should use default background gradient colors', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientBackground(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, AppColors.backgroundGradient);
      });

      testWidgets('should use default alignment values', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientBackground(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
      });
    });

    group('Custom Properties', () {
      testWidgets('should use custom colors when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');
        const customColors = [Colors.red, Colors.green, Colors.blue];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(child: testChild, colors: customColors),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, customColors);
      });

      testWidgets('should use custom begin alignment when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');
        const customBegin = Alignment.centerLeft;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(child: testChild, begin: customBegin),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.begin, customBegin);
      });

      testWidgets('should use custom end alignment when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');
        const customEnd = Alignment.centerRight;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(child: testChild, end: customEnd),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.end, customEnd);
      });

      testWidgets('should use all custom properties together', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Child');
        const customColors = [Colors.purple, Colors.orange];
        const customBegin = Alignment.topRight;
        const customEnd = Alignment.bottomLeft;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(
                child: testChild,
                colors: customColors,
                begin: customBegin,
                end: customEnd,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, customColors);
        expect(gradient.begin, customBegin);
        expect(gradient.end, customEnd);
      });
    });

    group('Child Widget Integration', () {
      testWidgets('should render complex child widget', (
        WidgetTester tester,
      ) async {
        final complexChild = Column(
          children: [
            const Text('Title'),
            const SizedBox(height: 16),
            const Text('Subtitle'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {}, child: const Text('Button')),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientBackground(child: complexChild)),
          ),
        );

        expect(find.text('Title'), findsOneWidget);
        expect(find.text('Subtitle'), findsOneWidget);
        expect(find.text('Button'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('should handle empty child gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientBackground(
                child: Container(), // Empty container as child
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsAtLeastNWidgets(1));
      });
    });
  });

  group('GradientCard', () {
    group('Widget Rendering', () {
      testWidgets('should render with required child', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        expect(find.text('Test Card Child'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });

      testWidgets('should render with all optional parameters', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customPadding = EdgeInsets.all(16);
        const customMargin = EdgeInsets.all(8);
        const customBorderRadius = 12.0;
        const customGradientColors = [Colors.blue, Colors.green];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(
                child: testChild,
                padding: customPadding,
                margin: customMargin,
                borderRadius: customBorderRadius,
                gradientColors: customGradientColors,
              ),
            ),
          ),
        );

        expect(find.text('Test Card Child'), findsOneWidget);
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });

    group('Default Properties', () {
      testWidgets('should use default card gradient colors', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, AppColors.cardGradient);
      });

      testWidgets('should use default padding', (WidgetTester tester) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        final paddings = find.byType(Padding);
        expect(paddings, findsAtLeastNWidgets(1));
      });

      testWidgets('should use default border radius', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, BorderRadius.circular(20));
      });

      testWidgets('should have default alignment for gradient', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
      });

      testWidgets('should have box shadow', (WidgetTester tester) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.boxShadow, isNotNull);
        expect(decoration.boxShadow!.length, 1);
        expect(decoration.boxShadow!.first.color, AppColors.shadowLight);
        expect(decoration.boxShadow!.first.blurRadius, 20);
        expect(decoration.boxShadow!.first.offset, const Offset(0, 10));
      });
    });

    group('Custom Properties', () {
      testWidgets('should use custom padding when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(child: testChild, padding: customPadding),
            ),
          ),
        );

        final paddings = find.byType(Padding);
        expect(paddings, findsAtLeastNWidgets(1));
      });

      testWidgets('should use custom margin when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customMargin = EdgeInsets.all(16);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(child: testChild, margin: customMargin),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.margin, customMargin);
      });

      testWidgets('should use custom border radius when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customBorderRadius = 15.0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(
                child: testChild,
                borderRadius: customBorderRadius,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;

        expect(
          decoration.borderRadius,
          BorderRadius.circular(customBorderRadius),
        );
      });

      testWidgets('should use custom gradient colors when provided', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customGradientColors = [Colors.red, Colors.yellow, Colors.green];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(
                child: testChild,
                gradientColors: customGradientColors,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, customGradientColors);
      });

      testWidgets('should use all custom properties together', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const customPadding = EdgeInsets.all(12);
        const customMargin = EdgeInsets.symmetric(vertical: 8);
        const customBorderRadius = 25.0;
        const customGradientColors = [Colors.purple, Colors.pink];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(
                child: testChild,
                padding: customPadding,
                margin: customMargin,
                borderRadius: customBorderRadius,
                gradientColors: customGradientColors,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;
        final paddings = find.byType(Padding);

        expect(container.margin, customMargin);
        expect(
          decoration.borderRadius,
          BorderRadius.circular(customBorderRadius),
        );
        expect(gradient.colors, customGradientColors);
        expect(paddings, findsAtLeastNWidgets(1));
      });
    });

    group('Child Widget Integration', () {
      testWidgets('should render complex child widget', (
        WidgetTester tester,
      ) async {
        final complexChild = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Card Title',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Card Description', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Action 1')),
                ElevatedButton(onPressed: () {}, child: const Text('Action 2')),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: complexChild)),
          ),
        );

        expect(find.byIcon(Icons.star), findsOneWidget);
        expect(find.text('Card Title'), findsOneWidget);
        expect(find.text('Card Description'), findsOneWidget);
        expect(find.text('Action 1'), findsOneWidget);
        expect(find.text('Action 2'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(2));
      });

      testWidgets('should handle empty child gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(
                child: Container(), // Empty container as child
              ),
            ),
          ),
        );

        expect(find.byType(Container), findsAtLeastNWidgets(1));
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle null margin', (WidgetTester tester) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: GradientCard(child: testChild, margin: null)),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.margin, isNull);
      });

      testWidgets('should handle zero border radius', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(child: testChild, borderRadius: 0.0),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, BorderRadius.circular(0.0));
      });

      testWidgets('should handle two color gradient', (
        WidgetTester tester,
      ) async {
        const testChild = Text('Test Card Child');
        const twoColors = [Colors.blue, Colors.blue];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GradientCard(child: testChild, gradientColors: twoColors),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient as LinearGradient;

        expect(gradient.colors, twoColors);
      });
    });
  });

  group('Integration Tests', () {
    testWidgets('should work together in a complex layout', (
      WidgetTester tester,
    ) async {
      final complexLayout = GradientBackground(
        child: Column(
          children: [
            const Text('App Title', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 20),
            GradientCard(
              child: Column(
                children: [
                  const Text('Card 1', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  const Text('This is the first card content'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GradientCard(
              child: Column(
                children: [
                  const Text('Card 2', style: TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  const Text('This is the second card content'),
                ],
              ),
            ),
          ],
        ),
      );

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: complexLayout)));

      expect(find.text('App Title'), findsOneWidget);
      expect(find.text('Card 1'), findsOneWidget);
      expect(find.text('Card 2'), findsOneWidget);
      expect(find.byType(GradientBackground), findsOneWidget);
      expect(find.byType(GradientCard), findsNWidgets(2));
    });
  });
}
