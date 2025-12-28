import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/responsive/responsive_utils.dart';

void main() {
  Future<void> withSize(
    WidgetTester tester,
    Size size,
    void Function(BuildContext) body,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: size),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              body(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  group('ResponsiveUtils padding and spacing', () {
    testWidgets('screen/card/list paddings return EdgeInsets', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        expect(ResponsiveUtils.screenPadding(ctx), isA<EdgeInsets>());
        expect(ResponsiveUtils.cardPadding(ctx), isA<EdgeInsets>());
        expect(ResponsiveUtils.listItemPadding(ctx), isA<EdgeInsets>());
        expect(ResponsiveUtils.sectionSpacing(ctx) > 0, true);
        expect(ResponsiveUtils.itemSpacing(ctx) > 0, true);
        expect(ResponsiveUtils.elementSpacing(ctx) > 0, true);
      });
    });

    testWidgets('icon and font sizes > 0', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        expect(ResponsiveUtils.iconSizeSmall(ctx) > 0, true);
        expect(ResponsiveUtils.iconSizeMedium(ctx) > 0, true);
        expect(ResponsiveUtils.iconSizeLarge(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeCaption(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeBody(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeBodyLarge(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeHeading(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeTitle(ctx) > 0, true);
        expect(ResponsiveUtils.fontSizeDisplay(ctx) > 0, true);
      });
    });

    testWidgets('radius helpers return > 0 and circular large', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        expect(ResponsiveUtils.radiusSmall(ctx) > 0, true);
        expect(ResponsiveUtils.radiusMedium(ctx) > 0, true);
        expect(ResponsiveUtils.radiusLarge(ctx) > 0, true);
        expect(ResponsiveUtils.radiusXLarge(ctx) > 0, true);
        expect(ResponsiveUtils.radiusCircular(ctx) > 0, true);
      });
    });
  });

  group('ResponsiveUtils dimensions and grid', () {
    testWidgets('avatar sizes are non-zero', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        expect(ResponsiveUtils.avatarSizeSmall(ctx).width > 0, true);
        expect(ResponsiveUtils.avatarSizeMedium(ctx).height > 0, true);
        expect(ResponsiveUtils.avatarSizeLarge(ctx).width > 0, true);
      });
    });

    testWidgets('gridCrossAxisCount adapts by device', (tester) async {
      await withSize(tester, const Size(350, 700), (ctx) {
        expect(ResponsiveUtils.gridCrossAxisCount(ctx), 1);
      });
      await withSize(tester, const Size(380, 700), (ctx) {
        expect(ResponsiveUtils.gridCrossAxisCount(ctx), 2);
      });
      await withSize(tester, const Size(700, 1000), (ctx) {
        expect(ResponsiveUtils.gridCrossAxisCount(ctx), 3);
        expect(ResponsiveUtils.gridCrossAxisCount(ctx, phone: 3, tablet: 5), 5);
      });
    });

    testWidgets('maxContentWidth and dialogWidth produce sensible values', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        expect(ResponsiveUtils.maxContentWidth(ctx) > 0, true);
        expect(ResponsiveUtils.dialogWidth(ctx) > 0, true);
      });
    });

    testWidgets('responsiveConstraints returns BoxConstraints', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        final c = ResponsiveUtils.responsiveConstraints(ctx, minWidth: 100, maxWidth: 200);
        expect(c.minWidth > 0, true);
        expect(c.maxWidth >= c.minWidth, true);
      });
    });

    testWidgets('responsiveTextTheme adjusts font sizes', (tester) async {
      await withSize(tester, const Size(390, 844), (ctx) {
        final theme = Theme.of(ctx).textTheme;
        final adjusted = ResponsiveUtils.responsiveTextTheme(ctx, theme);
        expect(adjusted.bodyMedium?.fontSize, isNotNull);
      });
    });
  });
}

