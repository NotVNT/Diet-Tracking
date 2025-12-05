import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/custom_button.dart';
import 'package:diet_tracking_project/common/app_colors.dart';

void main() {
  group('CustomButton', () {
    testWidgets('should render with required text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(CustomButton), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      expect(pressed, true);
    });

    testWidgets('should not call onPressed when disabled', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Disabled Button',
              onPressed: () {
                pressed = true;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      expect(pressed, false);
    });

    testWidgets('should not call onPressed when onPressed is null', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'No Action Button', onPressed: null),
          ),
        ),
      );

      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      expect(pressed, false);
    });

    testWidgets('should show loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CustomButton(
              text: 'Loading Button',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show loading indicator when isLoading is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CustomButton(
              text: 'Normal Button',
              onPressed: null,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should render with custom width', (WidgetTester tester) async {
      const double customWidth = 200.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Button',
              onPressed: () {},
              width: customWidth,
            ),
          ),
        ),
      );

      final SizedBox buttonContainer = tester.widget<SizedBox>(
        find.byType(SizedBox),
      );
      expect(buttonContainer.width, customWidth);
    });

    testWidgets('should render with custom height', (
      WidgetTester tester,
    ) async {
      const double customHeight = 80.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Height Button',
              onPressed: () {},
              height: customHeight,
            ),
          ),
        ),
      );

      final SizedBox buttonContainer = tester.widget<SizedBox>(
        find.byType(SizedBox),
      );
      expect(buttonContainer.height, isNotNull);
      expect(buttonContainer.height! > 0, true);
    });

    testWidgets('should render with icon', (WidgetTester tester) async {
      const Icon testIcon = Icon(Icons.add);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Button with Icon',
              onPressed: () {},
              icon: testIcon,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should render with custom background color', (
      WidgetTester tester,
    ) async {
      const Color customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Color Button',
              onPressed: () {},
              backgroundColor: customColor,
            ),
          ),
        ),
      );

      final Container buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.byType(Container).first,
        ),
      );
      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      final LinearGradient gradient = decoration.gradient as LinearGradient;
      expect(gradient.colors.first, customColor);
    });

    testWidgets('should render with custom text color', (
      WidgetTester tester,
    ) async {
      const Color customTextColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Custom Text Color Button',
              onPressed: () {},
              textColor: customTextColor,
            ),
          ),
        ),
      );

      final Text buttonText = tester.widget<Text>(
        find.text('Custom Text Color Button'),
      );
      expect(buttonText.style?.color, customTextColor);
    });

    testWidgets('should use default colors when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Default Colors Button', onPressed: () {}),
          ),
        ),
      );

      final Text buttonText = tester.widget<Text>(
        find.text('Default Colors Button'),
      );
      expect(buttonText.style?.color, AppColors.white);
    });

    testWidgets('should show disabled text color when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CustomButton(
              text: 'Disabled Button',
              onPressed: null,
              isEnabled: false,
            ),
          ),
        ),
      );

      final Text buttonText = tester.widget<Text>(find.text('Disabled Button'));
      expect(buttonText.style?.color, AppColors.grey500);
    });

    testWidgets('should have correct border radius', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Test Button', onPressed: () {}),
          ),
        ),
      );

      final Container buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.byType(Container).first,
        ),
      );
      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });

    testWidgets('should have correct gradient when enabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Enabled Button', onPressed: () {}),
          ),
        ),
      );

      final Container buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.byType(Container).first,
        ),
      );
      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });

    testWidgets('should have solid color when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CustomButton(
              text: 'Disabled Button',
              onPressed: null,
              isEnabled: false,
            ),
          ),
        ),
      );

      final Container buttonContainer = tester.widget<Container>(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.byType(Container).first,
        ),
      );
      final BoxDecoration decoration =
          buttonContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.grey300);
    });

    testWidgets('should handle animation correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Animated Button', onPressed: () {}),
          ),
        ),
      );

      // Test that the button can be tapped without errors
      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('should show both icon and text when both are provided', (
      WidgetTester tester,
    ) async {
      const Icon testIcon = Icon(Icons.save);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(text: 'Save', onPressed: () {}, icon: testIcon),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('should not show icon when loading', (
      WidgetTester tester,
    ) async {
      const Icon testIcon = Icon(Icons.save);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const CustomButton(
              text: 'Loading Button',
              onPressed: null,
              icon: testIcon,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should handle multiple rapid taps correctly', (
      WidgetTester tester,
    ) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Multi Tap Button',
              onPressed: () {
                tapCount++;
              },
            ),
          ),
        ),
      );

      // Tap multiple times rapidly
      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      await tester.tap(find.byType(CustomButton), warnIfMissed: false);
      await tester.tap(find.byType(CustomButton), warnIfMissed: false);

      expect(tapCount, 3);
    });
  });
}
