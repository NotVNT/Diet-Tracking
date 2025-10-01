import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/utils/weight_utils.dart';

void main() {
  group('WeightUtils conversions', () {
    test('kgToLb converts correctly', () {
      expect(WeightUtils.kgToLb(0), closeTo(0, 1e-12));
      expect(WeightUtils.kgToLb(1), closeTo(2.2046226218, 1e-12));
      expect(WeightUtils.kgToLb(70), closeTo(154.323583526, 1e-9));
    });

    test('lbToKg converts correctly', () {
      expect(WeightUtils.lbToKg(0), closeTo(0, 1e-12));
      expect(WeightUtils.lbToKg(2.2046226218), closeTo(1, 1e-10));
      expect(WeightUtils.lbToKg(154.323583526), closeTo(70, 1e-9));
    });

    test('kgToLb and lbToKg are inverses (property-based sample)', () {
      final sampleKgValues = <double>[0, 0.5, 1, 12.3, 55, 70.7, 123.45];
      for (final kg in sampleKgValues) {
        final roundTrip = WeightUtils.lbToKg(WeightUtils.kgToLb(kg));
        expect(roundTrip, closeTo(kg, 1e-10));
      }
    });
  });

  group('WeightUtils rounding', () {
    test('roundToStep rounds to nearest step', () {
      expect(WeightUtils.roundToStep(72.34, 0.5), closeTo(72.5, 1e-12));
      expect(WeightUtils.roundToStep(72.24, 0.5), closeTo(72.0, 1e-12));
      expect(WeightUtils.roundToStep(80.04, 0.1), closeTo(80.0, 1e-12));
      expect(WeightUtils.roundToStep(80.05, 0.1), closeTo(80.1, 1e-12));
    });
  });

  group('WeightUtils BMI', () {
    test('calculateBmi returns 0 for non-positive inputs', () {
      expect(
        WeightUtils.calculateBmi(weightKg: 0, heightCm: 170),
        closeTo(0, 1e-12),
      );
      expect(
        WeightUtils.calculateBmi(weightKg: 70, heightCm: 0),
        closeTo(0, 1e-12),
      );
      expect(
        WeightUtils.calculateBmi(weightKg: -10, heightCm: 170),
        closeTo(0, 1e-12),
      );
    });

    test('calculateBmi computes expected value', () {
      // 70kg, 175cm -> 70 / (1.75^2) = 22.857142857...
      final bmi = WeightUtils.calculateBmi(weightKg: 70, heightCm: 175);
      expect(bmi, closeTo(22.8571428571, 1e-9));
    });

    test('bmiDescription for key ranges', () {
      expect(WeightUtils.bmiDescription(0), '—');

      expect(WeightUtils.bmiDescription(18.4), 'Bạn đang thiếu cân');
      expect(WeightUtils.bmiDescription(18.5), 'Bạn có cân nặng bình thường');
      expect(WeightUtils.bmiDescription(24.9), 'Bạn có cân nặng bình thường');

      expect(WeightUtils.bmiDescription(25.0), 'Bạn đang thừa cân');
      expect(WeightUtils.bmiDescription(29.9), 'Bạn đang thừa cân');

      expect(WeightUtils.bmiDescription(30.0), 'Bạn béo phì (độ I)');
      expect(WeightUtils.bmiDescription(34.9), 'Bạn béo phì (độ I)');

      expect(WeightUtils.bmiDescription(35.0), 'Bạn béo phì (độ II)');
      expect(WeightUtils.bmiDescription(39.9), 'Bạn béo phì (độ II)');

      expect(
        WeightUtils.bmiDescription(40.0),
        'Bạn cần giảm cân nghiêm túc để bảo vệ sức khỏe',
      );
    });
  });
}
