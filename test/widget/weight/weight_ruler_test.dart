import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/widget/weight/weight_ruler.dart';

Widget _wrapWithMaterial(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('WeightRuler', () {
    testWidgets('renders Slider with correct defaults', (tester) async {
      double current = 70;
      await tester.pumpWidget(
        _wrapWithMaterial(
          WeightRuler(value: current, onChanged: (v) => current = v),
        ),
      );

      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);

      final Slider slider = tester.widget(sliderFinder);
      expect(slider.min, 20);
      expect(slider.max, 240);
      expect(slider.divisions, ((240 - 20) * 2).round());
      expect(slider.value, current);

      // Ensure the ticks painter exists (filter to our painter only)
      final ticksPaintFinder = find.byWidgetPredicate((w) {
        return w is CustomPaint &&
            w.painter?.runtimeType.toString() == '_WeightTicksPainter';
      });
      expect(ticksPaintFinder, findsOneWidget);
    });

    testWidgets('clamps value within provided range', (tester) async {
      double changed = -1;

      // Below min should clamp to min
      await tester.pumpWidget(
        _wrapWithMaterial(
          WeightRuler(
            min: 30,
            max: 100,
            value: 10, // below min
            onChanged: (v) => changed = v,
          ),
        ),
      );
      final Slider sliderBelow = tester.widget(find.byType(Slider));
      expect(sliderBelow.value, 30);

      // Above max should clamp to max
      await tester.pumpWidget(
        _wrapWithMaterial(
          WeightRuler(
            min: 30,
            max: 100,
            value: 120, // above max
            onChanged: (v) => changed = v,
          ),
        ),
      );
      final Slider sliderAbove = tester.widget(find.byType(Slider));
      expect(sliderAbove.value, 100);

      // Sanity: onChanged still wired (invoke directly)
      sliderAbove.onChanged?.call(80);
      expect(changed, 80);
    });

    testWidgets('invokes onChanged when value changes', (tester) async {
      double? lastChanged;
      await tester.pumpWidget(
        _wrapWithMaterial(
          WeightRuler(value: 75, onChanged: (v) => lastChanged = v),
        ),
      );

      final Slider slider = tester.widget(find.byType(Slider));
      slider.onChanged?.call(90);
      expect(lastChanged, 90);
    });

    testWidgets('applies accent color via SliderTheme', (tester) async {
      const accent = Color(0xFF123456);
      await tester.pumpWidget(
        _wrapWithMaterial(
          const WeightRuler(value: 60, onChanged: _noop, accent: accent),
        ),
      );

      final sliderThemeFinder = find.byType(SliderTheme);
      expect(sliderThemeFinder, findsOneWidget);
      final SliderTheme sliderTheme = tester.widget(sliderThemeFinder);

      // Colors are applied to the theme data
      expect(sliderTheme.data.thumbColor, accent);
      expect(sliderTheme.data.activeTrackColor, accent);
      expect(sliderTheme.data.inactiveTrackColor, const Color(0xFFE5E7EB));
      // Some Flutter versions quantize opacity slightly differently.
      final overlay = sliderTheme.data.overlayColor;
      expect(overlay, isNotNull);
      expect(overlay!.red, accent.red);
      expect(overlay.green, accent.green);
      expect(overlay.blue, accent.blue);
      expect(overlay.opacity, closeTo(0.08, 0.01));
    });
  });
}

void _noop(double _) {}
