import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';

void main() {
  group('NutritionCalculation', () {
    test('toJson/fromJson roundtrip', () {
      final model = NutritionCalculation(
        bmr: 1500,
        tdee: 2200,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 5.0,
        totalCaloriesNeeded: 38500,
        dailyCaloriesAdjustment: -500,
        targetCalories: 1800,
        targetDays: 77,
        isHealthy: true,
        warningMessage: 'OK',
      );

      final json = model.toJson();
      final parsed = NutritionCalculation.fromJson(json);

      expect(parsed.bmr, 1500);
      expect(parsed.tdee, 2200);
      expect(parsed.caloriesMax, 2300);
      expect(parsed.caloriesMin, 1700);
      expect(parsed.weightDifference, 5.0);
      expect(parsed.totalCaloriesNeeded, 38500);
      expect(parsed.dailyCaloriesAdjustment, -500);
      expect(parsed.targetCalories, 1800);
      expect(parsed.targetDays, 77);
      expect(parsed.isHealthy, true);
      expect(parsed.warningMessage, 'OK');
    });

    test('isCaloriesInSafeRange works at boundaries', () {
      final m1 = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 1700,
        targetDays: 1,
        isHealthy: true,
      );
      final m2 = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 2300,
        targetDays: 1,
        isHealthy: true,
      );
      final m3 = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 1500,
        targetDays: 1,
        isHealthy: true,
      );

      expect(m1.isCaloriesInSafeRange, true);
      expect(m2.isCaloriesInSafeRange, true);
      expect(m3.isCaloriesInSafeRange, false);
    });

    test('safetyLevel clamps to 100 within range and scales outside', () {
      final inRange = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 2000,
        targetDays: 1,
        isHealthy: true,
      );
      final below = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 850,
        targetDays: 1,
        isHealthy: false,
      );
      final above = NutritionCalculation(
        bmr: 1,
        tdee: 1,
        caloriesMax: 2300,
        caloriesMin: 1700,
        weightDifference: 0,
        totalCaloriesNeeded: 0,
        dailyCaloriesAdjustment: 0,
        targetCalories: 4600,
        targetDays: 1,
        isHealthy: false,
      );

      expect(inRange.safetyLevel, 100);
      expect(below.safetyLevel, closeTo(850 / 1700 * 100, 0.0001));
      expect(above.safetyLevel, closeTo(2300 / 4600 * 100, 0.0001));
    });
  });

  group('UserNutritionInfo', () {
    test('computed properties', () {
      final lose = UserNutritionInfo(
        age: 25,
        gender: 'Nam',
        heightCm: 170,
        currentWeightKg: 75,
        targetWeightKg: 70,
        activityLevel: 'Moderate',
      );
      final gain = UserNutritionInfo(
        age: 25,
        gender: 'Nữ',
        heightCm: 160,
        currentWeightKg: 45,
        targetWeightKg: 50,
        activityLevel: 'Low',
      );
      final maintain = UserNutritionInfo(
        age: 30,
        gender: 'Nữ',
        heightCm: 165,
        currentWeightKg: 55,
        targetWeightKg: 55,
        activityLevel: 'High',
      );

      expect(lose.isLosingWeight, true);
      expect(lose.isGainingWeight, false);
      expect(lose.isMaintainingWeight, false);
      expect(lose.weightDifference, 5);

      expect(gain.isLosingWeight, false);
      expect(gain.isGainingWeight, true);
      expect(gain.isMaintainingWeight, false);
      expect(gain.weightDifference, 5);

      expect(maintain.isMaintainingWeight, true);
      expect(maintain.weightDifference, 0);
    });

    test('toJson/fromJson roundtrip', () {
      final info = UserNutritionInfo(
        age: 28,
        gender: 'Nam',
        heightCm: 172.5,
        currentWeightKg: 68.2,
        targetWeightKg: 62.0,
        activityLevel: 'Moderate',
      );

      final parsed = UserNutritionInfo.fromJson(info.toJson());
      expect(parsed.age, 28);
      expect(parsed.gender, 'Nam');
      expect(parsed.heightCm, 172.5);
      expect(parsed.currentWeightKg, 68.2);
      expect(parsed.targetWeightKg, 62.0);
      expect(parsed.activityLevel, 'Moderate');
    });
  });
}

