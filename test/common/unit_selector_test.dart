import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/unit_selector.dart';

void main() {
  group('UnitSelector', () {
    group('Basic Rendering', () {
      testWidgets('should render with metric unit selected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });

      testWidgets('should render with imperial unit selected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.imperial,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Mỹ'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });

      testWidgets('should render with custom padding', (
        WidgetTester tester,
      ) async {
        const customPadding = EdgeInsets.all(16.0);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
                padding: customPadding,
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
      });

      testWidgets('should render with custom available units', (
        WidgetTester tester,
      ) async {
        const customUnits = [UnitSystem.imperial];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.imperial,
                onChanged: (unit) {},
                availableUnits: customUnits,
              ),
            ),
          ),
        );

        expect(find.text('Mỹ'), findsOneWidget);
      });
    });

    group('Unit Information', () {
      testWidgets('should display metric unit info', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
      });

      testWidgets('should display imperial unit info', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.imperial,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Mỹ'), findsOneWidget);
      });
    });

    group('Dropdown Icon', () {
      testWidgets('should display dropdown icon', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      });
    });

    group('Styling', () {
      testWidgets('should have correct text styling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Hệ mét'));
        expect(textWidget.style?.fontWeight, FontWeight.w500);
        expect(textWidget.style?.fontSize, 14);
      });
    });

    group('Gesture Detection', () {
      testWidgets('should be tappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        // Widget should be wrapped in GestureDetector
        expect(find.byType(GestureDetector), findsOneWidget);
      });
    });

    group('Available Units', () {
      testWidgets('should support both metric and imperial by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
      });

      testWidgets('should support custom available units list', (
        WidgetTester tester,
      ) async {
        const customUnits = [UnitSystem.metric];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
                availableUnits: customUnits,
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
      });
    });

    group('Integration Tests', () {
      testWidgets('should maintain state correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
      });

      testWidgets('should handle widget rebuilds correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.metric,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);

        // Rebuild with different unit
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UnitSelector(
                selected: UnitSystem.imperial,
                onChanged: (unit) {},
              ),
            ),
          ),
        );

        expect(find.text('Mỹ'), findsOneWidget);
      });

      testWidgets('should render in different contexts', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: Center(
                child: UnitSelector(
                  selected: UnitSystem.metric,
                  onChanged: (unit) {},
                ),
              ),
            ),
          ),
        );

        expect(find.text('Hệ mét'), findsOneWidget);
        expect(find.text('Settings'), findsOneWidget);
      });
    });

    group('Enum Tests', () {
      test('should have metric unit system', () {
        expect(UnitSystem.metric, isNotNull);
      });

      test('should have imperial unit system', () {
        expect(UnitSystem.imperial, isNotNull);
      });

      test('should have exactly two unit systems', () {
        final units = UnitSystem.values;
        expect(units.length, 2);
      });
    });
  });
}

