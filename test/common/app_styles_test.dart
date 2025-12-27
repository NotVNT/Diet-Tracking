import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/app_styles.dart';
import 'package:diet_tracking_project/common/app_colors.dart';

void main() {
  group('AppStyles', () {
    group('Text Styles', () {
      testWidgets('should have correct heading1 style', (
        WidgetTester tester,
      ) async {
        final TextStyle heading1 = AppStyles.heading1;

        expect(heading1.fontSize, 32);
        expect(heading1.fontWeight, FontWeight.bold);
        expect(heading1.color, AppColors.black);
        expect(heading1.height, 1.2);
      });

      testWidgets('should have correct heading2 style', (
        WidgetTester tester,
      ) async {
        final TextStyle heading2 = AppStyles.heading2;

        expect(heading2.fontSize, 24);
        expect(heading2.fontWeight, FontWeight.bold);
        expect(heading2.color, AppColors.black);
        expect(heading2.height, 1.3);
      });

      testWidgets('should have correct bodyLarge style', (
        WidgetTester tester,
      ) async {
        final TextStyle bodyLarge = AppStyles.bodyLarge;

        expect(bodyLarge.fontSize, 16);
        expect(bodyLarge.fontWeight, FontWeight.normal);
        expect(bodyLarge.color, AppColors.grey600);
        expect(bodyLarge.height, 1.5);
      });

      testWidgets('should have correct bodyMedium style', (
        WidgetTester tester,
      ) async {
        final TextStyle bodyMedium = AppStyles.bodyMedium;

        expect(bodyMedium.fontSize, 14);
        expect(bodyMedium.fontWeight, FontWeight.normal);
        expect(bodyMedium.color, AppColors.grey600);
        expect(bodyMedium.height, 1.4);
      });

      testWidgets('should have correct labelMedium style', (
        WidgetTester tester,
      ) async {
        final TextStyle labelMedium = AppStyles.labelMedium;

        expect(labelMedium.fontSize, 14);
        expect(labelMedium.fontWeight, FontWeight.w500);
        expect(labelMedium.color, AppColors.black);
      });

      testWidgets('should have correct buttonText style', (
        WidgetTester tester,
      ) async {
        final TextStyle buttonText = AppStyles.buttonText;

        expect(buttonText.fontSize, 16);
        expect(buttonText.fontWeight, FontWeight.w600);
        expect(buttonText.color, AppColors.white);
      });

      testWidgets('should have correct linkText style', (
        WidgetTester tester,
      ) async {
        final TextStyle linkText = AppStyles.linkText;

        expect(linkText.fontSize, 14);
        expect(linkText.fontWeight, FontWeight.w500);
        expect(linkText.color, AppColors.primary);
      });
    });

    group('Input Decorations', () {
      testWidgets('should create basic input decoration', (
        WidgetTester tester,
      ) async {
        final InputDecoration decoration = AppStyles.inputDecoration;

        expect(decoration.border, InputBorder.none);
        expect(
          decoration.contentPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );
      });

      testWidgets('should create input decoration with hint', (
        WidgetTester tester,
      ) async {
        const String hint = 'Test hint';
        final InputDecoration decoration = AppStyles.inputDecorationWithHint(
          hint,
        );

        expect(decoration.hintText, hint);
        expect(decoration.border, InputBorder.none);
        expect(
          decoration.contentPadding,
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        );
      });
    });

    group('Box Decorations', () {
      testWidgets('should create card decoration', (WidgetTester tester) async {
        final BoxDecoration decoration = AppStyles.cardDecoration;

        expect(decoration.color, AppColors.white);
        expect(decoration.borderRadius, BorderRadius.circular(20));
        expect(decoration.boxShadow, isA<List<BoxShadow>>());
        expect(decoration.boxShadow!.length, 1);
        expect(decoration.boxShadow!.first.color, AppColors.shadowLight.withAlpha(20));
        expect(decoration.boxShadow!.first.blurRadius, 8);
        expect(decoration.boxShadow!.first.offset, const Offset(0, 4));
      });

      testWidgets('should create input box decoration', (
        WidgetTester tester,
      ) async {
        final BoxDecoration decoration = AppStyles.inputBoxDecoration;

        expect(decoration.color, AppColors.white);
        expect(decoration.borderRadius, BorderRadius.circular(16));
        expect(decoration.border, isA<Border>());
        expect(decoration.boxShadow, isA<List<BoxShadow>>());
        expect(decoration.boxShadow!.length, 1);
      });

      testWidgets('should create input decoration with focus', (
        WidgetTester tester,
      ) async {
        final BoxDecoration focusedDecoration =
            AppStyles.inputDecorationWithFocus(true);
        final BoxDecoration unfocusedDecoration =
            AppStyles.inputDecorationWithFocus(false);

        expect(focusedDecoration.color, AppColors.white);
        expect(focusedDecoration.borderRadius, BorderRadius.circular(16));
        expect(focusedDecoration.border, isA<Border>());

        expect(unfocusedDecoration.color, AppColors.white);
        expect(unfocusedDecoration.borderRadius, BorderRadius.circular(16));
        expect(unfocusedDecoration.border, isA<Border>());
      });

      testWidgets('should create button decoration', (
        WidgetTester tester,
      ) async {
        final BoxDecoration decoration = AppStyles.buttonDecoration;

        expect(decoration.gradient, isA<LinearGradient>());
        expect(decoration.borderRadius, BorderRadius.circular(16));
        expect(decoration.boxShadow, isA<List<BoxShadow>>());
        expect(decoration.boxShadow!.length, 1);
      });

      testWidgets('should create disabled button decoration', (
        WidgetTester tester,
      ) async {
        final BoxDecoration decoration = AppStyles.disabledButtonDecoration;

        expect(decoration.color, AppColors.grey300);
        expect(decoration.borderRadius, BorderRadius.circular(16));
      });
    });

    group('Spacing Constants', () {
      test('should have correct spacing values', () {
        expect(AppStyles.spacingXS, 4.0);
        expect(AppStyles.spacingS, 8.0);
        expect(AppStyles.spacingM, 16.0);
        expect(AppStyles.spacingL, 24.0);
        expect(AppStyles.spacingXL, 32.0);
        expect(AppStyles.spacingXXL, 40.0);
      });
    });

    group('Border Radius Constants', () {
      test('should have correct radius values', () {
        expect(AppStyles.radiusS, 8.0);
        expect(AppStyles.radiusM, 12.0);
        expect(AppStyles.radiusL, 16.0);
        expect(AppStyles.radiusXL, 20.0);
      });
    });

    group('Widget Integration Tests', () {
      testWidgets('should render text with heading1 style', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Text('Test Heading', style: AppStyles.heading1),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Test Heading'));
        expect(textWidget.style, AppStyles.heading1);
      });

      testWidgets('should render container with card decoration', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: AppStyles.cardDecoration,
                child: const Text('Card Content'),
              ),
            ),
          ),
        );

        final containerWidget = tester.widget<Container>(
          find.byType(Container),
        );
        expect(containerWidget.decoration, AppStyles.cardDecoration);
      });

      testWidgets('should render text field with input decoration', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TextField(
                decoration: AppStyles.inputDecorationWithHint('Enter text'),
              ),
            ),
          ),
        );

        final textFieldWidget = tester.widget<TextField>(
          find.byType(TextField),
        );
        expect(textFieldWidget.decoration?.hintText, 'Enter text');
      });
    });
  });
}


