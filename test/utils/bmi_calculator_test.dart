import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/utils/bmi_calculator.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

void main() {
  group('BmiCalculator.computeBmi', () {
    test('returns 0 when height is null or <= 0', () {
      expect(BmiCalculator.computeBmi(70, null), 0);
      expect(BmiCalculator.computeBmi(70, 0), 0);
      expect(BmiCalculator.computeBmi(70, -10), 0);
    });

    test('computes BMI correctly', () {
      final bmi = BmiCalculator.computeBmi(81, 180); // ~25.0
      expect(bmi, closeTo(25.0, 0.01));
    });
  });

  group('BmiCalculator.bmiDescription', () {
    Future<String> desc(WidgetTester tester, double bmi) async {
      late String text;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              text = BmiCalculator.bmiDescription(context, bmi);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      return text;
    }

    testWidgets('returns localized messages for ranges', (tester) async {
      expect(await desc(tester, 0), 'Please enter height to calculate BMI.');
      expect(await desc(tester, 17), 'You are underweight.');
      expect(await desc(tester, 23), 'You have a normal weight.');
      expect(await desc(tester, 27), 'You are overweight.');
      expect(await desc(tester, 31), 'You need to lose weight seriously to protect your health.');
    });
  });
}

