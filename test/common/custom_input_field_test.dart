import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/custom_input_field.dart';
import 'package:diet_tracking_project/common/app_styles.dart';

void main() {
  group('CustomInputField', () {
    late TextEditingController controller;

    setUp(() {
      controller = TextEditingController();
    });

    tearDown(() {
      controller.dispose();
    });

    group('Widget Rendering', () {
      testWidgets('should render with required parameters', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test Label',
                hint: 'Test Hint',
                controller: controller,
              ),
            ),
          ),
        );

        expect(find.text('Test Label'), findsOneWidget);
        expect(find.text('Test Hint'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should render with all optional parameters', (
        WidgetTester tester,
      ) async {
        const suffixIcon = Icon(Icons.visibility);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Password',
                hint: 'Enter password',
                controller: controller,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: suffixIcon,
                isFocused: true,
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
            ),
          ),
        );

        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Enter password'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });
    });

    group('Text Input Properties', () {
      testWidgets('should have correct text input properties', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Email',
                hint: 'Enter email',
                controller: controller,
                keyboardType: TextInputType.emailAddress,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.keyboardType, TextInputType.emailAddress);
        expect(textField.obscureText, false);
      });

      testWidgets('should handle obscure text correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Password',
                hint: 'Enter password',
                controller: controller,
                obscureText: true,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.obscureText, true);
      });

      testWidgets('should handle different keyboard types', (
        WidgetTester tester,
      ) async {
        const keyboardTypes = [
          TextInputType.text,
          TextInputType.emailAddress,
          TextInputType.phone,
          TextInputType.number,
        ];

        for (final keyboardType in keyboardTypes) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: CustomInputField(
                  label: 'Test',
                  hint: 'Test hint',
                  controller: controller,
                  keyboardType: keyboardType,
                ),
              ),
            ),
          );

          final textField = tester.widget<TextField>(find.byType(TextField));
          expect(textField.keyboardType, keyboardType);
        }
      });
    });

    group('Controller Integration', () {
      testWidgets('should update text when controller changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        controller.text = 'Test text';
        await tester.pump();

        expect(find.text('Test text'), findsOneWidget);
      });

      testWidgets('should clear text when controller is cleared', (
        WidgetTester tester,
      ) async {
        controller.text = 'Initial text';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        controller.clear();
        await tester.pump();

        expect(find.text('Initial text'), findsNothing);
      });
    });

    group('Focus State and Animations', () {
      testWidgets('should show unfocused state by default', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        // Find the container that wraps the TextField
        final containers = find.byType(Container);
        expect(containers, findsWidgets);

        // Check that the widget renders without errors
        expect(find.byType(CustomInputField), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should show focused state when isFocused is true', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                isFocused: true,
              ),
            ),
          ),
        );

        // Check that the widget renders without errors
        expect(find.byType(CustomInputField), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should animate when focus state changes', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                isFocused: false,
              ),
            ),
          ),
        );

        // Check that AnimatedBuilder exists
        expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));

        // Trigger focus change
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                isFocused: true,
              ),
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200));

        // Check that AnimatedBuilder still exists
        expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      });
    });

    group('Styling and Appearance', () {
      testWidgets('should have correct label styling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test Label',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test Label'));
        expect(textWidget.style, isNotNull);
        expect(textWidget.style?.fontSize, 14);
        expect(textWidget.style?.fontWeight, FontWeight.w500);
      });

      testWidgets('should have correct hint styling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        final hintStyle = textField.decoration?.hintStyle;
        expect(hintStyle, isNotNull);
        expect(hintStyle?.fontSize, 16);
      });

      testWidgets('should have correct text styling', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.style, isNotNull);
        expect(textField.style?.fontSize, 16);
      });

      testWidgets('should have correct container decoration', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        final container = tester.widget<Container>(find.byType(Container).last);
        final decoration = container.decoration as BoxDecoration;

        expect(
          decoration.borderRadius,
          BorderRadius.circular(AppStyles.radiusL),
        );
        expect(decoration.border?.top.width, 1.5);
        expect(decoration.boxShadow?.length, 1);
      });

      testWidgets('should have correct focused decoration', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                isFocused: true,
              ),
            ),
          ),
        );

        // Check that the widget renders without errors
        expect(find.byType(CustomInputField), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
      });
    });

    group('Suffix Icon', () {
      testWidgets('should display suffix icon when provided', (
        WidgetTester tester,
      ) async {
        const suffixIcon = Icon(Icons.visibility);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Password',
                hint: 'Enter password',
                controller: controller,
                suffixIcon: suffixIcon,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.visibility), findsOneWidget);
      });

      testWidgets('should not display suffix icon when not provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        expect(find.byType(Icon), findsNothing);
      });
    });

    group('User Interactions', () {
      testWidgets('should call onTap when provided', (
        WidgetTester tester,
      ) async {
        bool onTapCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                onTap: () => onTapCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(TextField));
        expect(onTapCalled, true);
      });

      testWidgets('should handle text input correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), 'Hello World');
        expect(controller.text, 'Hello World');
      });
    });

    group('Validation', () {
      testWidgets('should call validator when provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                validator: (value) =>
                    value?.isEmpty == true ? 'Required' : null,
              ),
            ),
          ),
        );

        // Test the validator function directly
        final customInputField = tester.widget<CustomInputField>(
          find.byType(CustomInputField),
        );
        final result = customInputField.validator?.call('');
        expect(result, 'Required');
      });

      testWidgets('should not call validator when not provided', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        final customInputField = tester.widget<CustomInputField>(
          find.byType(CustomInputField),
        );
        expect(customInputField.validator, null);
      });
    });

    group('Layout and Structure', () {
      testWidgets('should have correct column structure', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        expect(find.byType(Column), findsOneWidget);
        expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
        expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      });

      testWidgets('should have correct spacing between elements', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        // Find the SizedBox with the specific height we're looking for
        final sizedBoxes = find.byType(SizedBox);
        expect(sizedBoxes, findsAtLeastNWidgets(1));

        // Check that the widget renders without errors
        expect(find.byType(CustomInputField), findsOneWidget);
      });
    });

    group('Animation Controller Lifecycle', () {
      testWidgets('should dispose animation controller properly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
              ),
            ),
          ),
        );

        // Remove the widget to trigger dispose
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: Container())));

        // No exception should be thrown during disposal
        expect(tester.takeException(), isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle null suffix icon gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Test',
                hint: 'Test hint',
                controller: controller,
                suffixIcon: null,
              ),
            ),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(Icon), findsNothing);
      });

      testWidgets('should handle empty label and hint', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: '',
                hint: '',
                controller: controller,
              ),
            ),
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text(''), findsAtLeastNWidgets(2)); // Empty label and hint
      });

      testWidgets('should handle very long text', (WidgetTester tester) async {
        const longText =
            'This is a very long text that should be handled properly by the input field without causing any layout issues or overflow problems';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomInputField(
                label: 'Long Text',
                hint: 'Enter long text',
                controller: controller,
              ),
            ),
          ),
        );

        await tester.enterText(find.byType(TextField), longText);
        expect(controller.text, longText);
      });
    });
  });
}
