import 'dart:async';

import 'package:diet_tracking_project/widget/height/height_responsive_devices.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Map<String, double>> _measureForSize(
  WidgetTester tester,
  Size size,
) async {
  final results = <String, double>{};
  final completer = Completer<void>();

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            results['ws'] = HeightResponsiveDevices.widthScale(context);
            results['hs'] = HeightResponsiveDevices.heightScale(context);
            results['s'] = HeightResponsiveDevices.scale(context);
            results['dim100'] = HeightResponsiveDevices.dim(context, 100);
            results['font16'] = HeightResponsiveDevices.font(context, 16);
            results['wheel'] = HeightResponsiveDevices.wheelHeight(context);
            if (!completer.isCompleted) completer.complete();
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );

  await completer.future;
  return results;
}

void main() {
  group('HeightResponsiveDevices', () {
    testWidgets('baseline 390x844 ~ scale 1.0', (tester) async {
      final r = await _measureForSize(tester, const Size(390, 844));
      expect(r['ws']!, closeTo(1.0, 1e-6));
      expect(r['hs']!, closeTo(1.0, 1e-6));
      expect(r['s']!, closeTo(1.0, 1e-6));
      expect(r['dim100']!, closeTo(100.0, 1e-6));
      expect(r['font16']!, closeTo(16.0, 1e-6));
      // wheel uses height scale -> 400
      expect(r['wheel']!, closeTo(400.0, 1e-6));
    });

    testWidgets('small phone: width not clamped, height clamped to 0.80', (
      tester,
    ) async {
      // 320x568: widthScale = 320/390 = ~0.820512..., heightScale = 568/844 = ~0.672 -> clamped to 0.80
      final r = await _measureForSize(tester, const Size(320, 568));
      const expectedWs = 320 / 390; // ~0.8205128205
      const expectedHs = 0.80; // clamped
      final expectedS = (expectedWs + expectedHs) / 2; // ~0.81025641025
      expect(r['ws']!, closeTo(expectedWs, 1e-9));
      expect(r['hs']!, closeTo(expectedHs, 1e-9));
      expect(r['s']!, closeTo(expectedS, 1e-9));
      // dim scales: 100 * expectedS
      expect(r['dim100']!, closeTo(100 * expectedS, 1e-9));
      // font scales: 16 * expectedS, within [12, 64]
      expect(r['font16']!, closeTo(16 * expectedS, 1e-9));
      // wheel uses height scale with clamp range [260, 560]: 400 * 0.8 = 320
      expect(r['wheel']!, closeTo(320.0, 1e-9));
    });

    testWidgets('very large phone clamps to max 1.35', (tester) async {
      // Make both width and height significantly larger than base to trigger clamp
      final r = await _measureForSize(tester, const Size(1242, 2688));
      expect(r['ws']!, closeTo(1.35, 1e-6));
      expect(r['hs']!, closeTo(1.35, 1e-6));
      expect(r['s']!, closeTo(1.35, 1e-6));
      // dim scales: 100 * 1.35 = 135
      expect(r['dim100']!, closeTo(135.0, 1e-6));
      // font scales then clamped to <= 64: 16 * 1.35 = 21.6
      expect(r['font16']!, closeTo(21.6, 1e-6));
      // wheel uses height scale with clamp range: 400 * 1.35 = 540
      expect(r['wheel']!, closeTo(540.0, 1e-6));
    });

    testWidgets('font min and max clamps are respected', (tester) async {
      // Small device to test min clamp
      final small = await _measureForSize(tester, const Size(200, 300));
      // base 10 -> scaled 10 * 0.8 = 8, but min is 12
      late double minClamped;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(200, 300)),
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox.shrink(),
          ),
        ),
      );
      // Recompute font explicitly to assert clamp boundaries
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(200, 300)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                minClamped = HeightResponsiveDevices.font(context, 10);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(minClamped, 12);
      // Large device to test max clamp
      late double maxClamped;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(2000, 4000)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Builder(
              builder: (context) {
                maxClamped = HeightResponsiveDevices.font(context, 80);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      expect(maxClamped, 64);
      // Sanity: small previously computed map exists
      expect(small['s']!, greaterThan(0));
    });
  });
}
