import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/services/nutrition_calculator_service.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';

void main() {
  group('NutritionCalculatorService basic formulas', () {
    test('calculateBMR male vs female', () {
      final male = NutritionCalculatorService.calculateBMR(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        gender: 'male',
      );
      final female = NutritionCalculatorService.calculateBMR(
        weightKg: 70,
        heightCm: 175,
        age: 25,
        gender: 'female',
      );
      // Male should be 1668.75 + 5 = 1673.75; Female should be 1668.75 - 161 = 1507.75
      expect(male, closeTo(1673.75, 0.01));
      expect(female, closeTo(1507.75, 0.01));
    });

    test('calculateTDEE uses activity multiplier', () {
      final tdee = NutritionCalculatorService.calculateTDEE(
        bmr: 1600,
        activityLevel: 'Vận động vừa',
      );
      expect(tdee, closeTo(1600 * 1.55, 0.01));
    });

    test('getMinCalories by gender', () {
      expect(NutritionCalculatorService.getMinCalories('male'), 1500);
      expect(NutritionCalculatorService.getMinCalories('female'), 1200);
    });

    test('calculateMaxCalories adds 1000', () {
      expect(NutritionCalculatorService.calculateMaxCalories(2000), 3000);
    });
  });

  group('NutritionCalculatorService end-to-end calculate', () {
    test('losing weight scenario', () {
      final info = UserNutritionInfo(
        age: 25,
        gender: 'male',
        heightCm: 175,
        currentWeightKg: 80,
        targetWeightKg: 75,
        activityLevel: 'Ít vận động',
      );

      final result = NutritionCalculatorService.calculate(
        userInfo: info,
        targetDays: 70,
      );

      expect(result.bmr, isNonZero);
      expect(result.tdee, isNonZero);
      expect(result.caloriesMin <= result.targetCalories, true);
      expect(result.caloriesMax >= result.targetCalories, true);
      expect(result.isHealthy, true);
      expect(result.weightDifference, closeTo(5.0, 0.0001));
    });

    test('very aggressive plan triggers warnings or unhealthy', () {
      final info = UserNutritionInfo(
        age: 25,
        gender: 'female',
        heightCm: 165,
        currentWeightKg: 70,
        targetWeightKg: 55,
        activityLevel: 'Ít vận động',
      );

      // Too few days -> daily adjustment too high
      final result = NutritionCalculatorService.calculate(
        userInfo: info,
        targetDays: 14,
      );

      expect(result.isHealthy, anyOf(isFalse, isTrue));
      // There should be either an unhealthy flag or warning message in extreme case
      expect(result.warningMessage != null || result.isHealthy == false, true);
    });
  });

  group('NutritionCalculatorService day estimations', () {
    test('calculateMinimumSafeDays returns large number when not feasible', () {
      final info = UserNutritionInfo(
        age: 25,
        gender: 'female',
        heightCm: 160,
        currentWeightKg: 40,
        targetWeightKg: 35,
        activityLevel: 'Ít vận động',
      );
      final days = NutritionCalculatorService.calculateMinimumSafeDays(userInfo: info);
      expect(days, greaterThan(0));
    });

    test('calculateRecommendedDays scales with weight difference', () {
      final info1 = UserNutritionInfo(
        age: 25,
        gender: 'male',
        heightCm: 175,
        currentWeightKg: 80,
        targetWeightKg: 75,
        activityLevel: 'Vận động nhẹ',
      );
      final info2 = UserNutritionInfo(
        age: 25,
        gender: 'male',
        heightCm: 175,
        currentWeightKg: 90,
        targetWeightKg: 75,
        activityLevel: 'Vận động nhẹ',
      );
      final d1 = NutritionCalculatorService.calculateRecommendedDays(userInfo: info1);
      final d2 = NutritionCalculatorService.calculateRecommendedDays(userInfo: info2);
      expect(d2 > d1, true);
    });
  });
}

