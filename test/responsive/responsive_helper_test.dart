import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/responsive/responsive_helper.dart';

void main() {
  Future<void> _withSize(WidgetTester tester, Size size, void Function(BuildContext) body) async {
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

  group('ResponsiveHelper deviceType', () {
    testWidgets('classifies by width thresholds', (tester) async {
      await _withSize(tester, const Size(350, 700), (ctx) {
        expect(ResponsiveHelper.of(ctx).deviceType, DeviceType.smallPhone);
      });
      await _withSize(tester, const Size(380, 700), (ctx) {
        expect(ResponsiveHelper.of(ctx).deviceType, DeviceType.phone);
      });
      await _withSize(tester, const Size(500, 900), (ctx) {
        expect(ResponsiveHelper.of(ctx).deviceType, DeviceType.largePhone);
      });
      await _withSize(tester, const Size(700, 1000), (ctx) {
        expect(ResponsiveHelper.of(ctx).deviceType, DeviceType.smallTablet);
      });
      await _withSize(tester, const Size(1000, 1200), (ctx) {
        expect(ResponsiveHelper.of(ctx).deviceType, DeviceType.tablet);
      });
    });
  });

  group('ResponsiveHelper scaling', () {
    testWidgets('fontSize and spacing are clamped reasonably', (tester) async {
      await _withSize(tester, const Size(390, 844), (ctx) {
        final r = ResponsiveHelper.of(ctx);
        final f = r.fontSize(20);
        final s = r.spacing(16);
        expect(f, inExclusiveRange(17, 25));
        expect(s, inInclusiveRange(12.8, 21.6));
      });
    });

    testWidgets('edgePadding produces non-zero padding', (tester) async {
      await _withSize(tester, const Size(390, 844), (ctx) {
        final r = ResponsiveHelper.of(ctx);
        final p = r.edgePadding(horizontal: 16, vertical: 20);
        expect(p.left > 0, true);
        expect(p.top > 0, true);
      });
    });
  });
}

