import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/model/body_info_model.dart';

void main() {
  group('BodyInfoModel', () {
    test('toJson includes supported fields (health is not persisted)', () {
      const model = BodyInfoModel(
        heightCm: 170.5,
        weightKg: 65.2,
        goalWeightKg: 60.0,
        health: HealthStatus.good,
        medicalConditions: ['a', 'b'],
        allergies: ['x'],
      );
      final json = model.toJson();

      expect(json['heightCm'], 170.5);
      expect(json['weightKg'], 65.2);
      expect(json['goalWeightKg'], 60.0);
      expect(json['medicalConditions'], ['a', 'b']);
      expect(json['allergies'], ['x']);
      expect(json.containsKey('health'), isFalse);
    });

    test('fromJson parses doubles, lists and health correctly', () {
      final parsed = BodyInfoModel.fromJson({
        'heightCm': 160,
        'weightKg': 50,
        'goalWeightKg': 48.5,
        'health': 'excellent',
        'medicalConditions': 'a, b , c',
        'allergies': ['x', 'y'],
      });

      expect(parsed.heightCm, 160.0);
      expect(parsed.weightKg, 50.0);
      expect(parsed.goalWeightKg, 48.5);
      expect(parsed.health, HealthStatus.excellent);
      expect(parsed.medicalConditions, ['a', 'b', 'c']);
      expect(parsed.allergies, ['x', 'y']);
    });

    test('fromJson with invalid health maps to unknown', () {
      final parsed = BodyInfoModel.fromJson({'health': 'not-a-status'});
      expect(parsed.health, HealthStatus.unknown);
    });

    test('bmi returns expected value or null for invalid inputs', () {
      expect(
        const BodyInfoModel(heightCm: 180, weightKg: 81).bmi,
        closeTo(25.0, 0.001),
      );
      expect(const BodyInfoModel(heightCm: null, weightKg: 70).bmi, isNull);
      expect(const BodyInfoModel(heightCm: 170, weightKg: null).bmi, isNull);
      expect(const BodyInfoModel(heightCm: 0, weightKg: 70).bmi, isNull);
      expect(const BodyInfoModel(heightCm: -10, weightKg: 70).bmi, isNull);
    });

    test('bmiCategory maps by BMI ranges', () {
      expect(
        const BodyInfoModel(heightCm: 170, weightKg: 50).bmiCategory,
        BmiCategory.underweight,
      );
      expect(
        const BodyInfoModel(heightCm: 170, weightKg: 65).bmiCategory,
        BmiCategory.normal,
      );
      expect(
        const BodyInfoModel(heightCm: 170, weightKg: 80).bmiCategory,
        BmiCategory.overweight,
      );
      expect(
        const BodyInfoModel(heightCm: 170, weightKg: 95).bmiCategory,
        BmiCategory.obese,
      );
    });

    test('copyWith updates only provided fields', () {
      const original = BodyInfoModel(heightCm: 170, weightKg: 65);
      final updated = original.copyWith(weightKg: 70, goalWeightKg: 60);
      expect(updated.heightCm, 170);
      expect(updated.weightKg, 70);
      expect(updated.goalWeightKg, 60);
    });
  });
}
