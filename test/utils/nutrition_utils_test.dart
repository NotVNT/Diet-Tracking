import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/utils/nutrition_utils.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';

void main() {
  group('NutritionUtils activity helpers', () {
    test('getActivityMultiplier and getActivityLevelName roundtrip', () {
      final m = NutritionUtils.getActivityMultiplier('Vận động vừa');
      expect(m, 1.55);
      expect(NutritionUtils.getActivityLevelName(m), 'Vận động vừa');

      // Unknown returns default 1.2 and maps to default name
      final m2 = NutritionUtils.getActivityMultiplier('UNKNOWN');
      expect(m2, 1.2);
      expect(NutritionUtils.getActivityLevelName(999), 'Ít vận động');
    });
  });

  group('NutritionUtils formatting', () {
    test('formatCalories/formatWeight', () {
      expect(NutritionUtils.formatCalories(1234.56), '1235 cal');
      expect(NutritionUtils.formatWeight(65.23), '65.2 kg');
    });

    test('formatDays covers ranges', () {
      expect(NutritionUtils.formatDays(3), '3 ngày');
      expect(NutritionUtils.formatDays(14), contains('≈'));
      expect(NutritionUtils.formatDays(60), contains('tháng'));
      expect(NutritionUtils.formatDays(400), contains('năm'));
    });
  });

  group('NutritionUtils gender helpers', () {
    test('isValidGender/normalizeGender', () {
      expect(NutritionUtils.isValidGender('male'), true);
      expect(NutritionUtils.isValidGender('female'), true);
      expect(NutritionUtils.isValidGender('Nam'), true);
      expect(NutritionUtils.isValidGender('Nữ'), true);
      expect(NutritionUtils.isValidGender('other'), false);

      expect(NutritionUtils.normalizeGender('male'), 'Nam');
      expect(NutritionUtils.normalizeGender('female'), 'Nữ');
      expect(NutritionUtils.normalizeGender('Nam'), 'Nam');
    });
  });

  group('NutritionUtils BMI and ideal weight', () {
    test('calculateBMI and classifyBMI', () {
      final bmi = NutritionUtils.calculateBMI(70, 175); // ~22.86
      expect(bmi, closeTo(22.86, 0.01));
      expect(NutritionUtils.classifyBMI(bmi), 'Bình thường');
      expect(NutritionUtils.classifyBMI(17), 'Thiếu cân');
      expect(NutritionUtils.classifyBMI(27), 'Thừa cân');
      expect(NutritionUtils.classifyBMI(32), 'Béo phì');
    });

    test('calculateIdealWeight male vs female differ', () {
      final male = NutritionUtils.calculateIdealWeight(175, 'male');
      final female = NutritionUtils.calculateIdealWeight(175, 'female');
      expect(male > female, true);
    });
  });

  group('NutritionUtils calories/weight change helpers', () {
    test('calculateCaloriesForWeightChange', () {
      expect(NutritionUtils.calculateCaloriesForWeightChange(2), 2 * 7700);
    });

    test('calculateWeightChangeRate and safety checks/messages', () {
      final slow = NutritionUtils.calculateWeightChangeRate(1, 56); // ~0.125/wk
      final moderate = NutritionUtils.calculateWeightChangeRate(2, 28); // ~0.5/wk
      final fast = NutritionUtils.calculateWeightChangeRate(4, 28); // ~1.0/wk
      final tooFast = NutritionUtils.calculateWeightChangeRate(5, 14); // ~2.5/wk

      expect(NutritionUtils.isSafeWeightChangeRate(slow), false);
      expect(NutritionUtils.isSafeWeightChangeRate(moderate), true);
      expect(NutritionUtils.isSafeWeightChangeRate(fast), true);
      expect(NutritionUtils.isSafeWeightChangeRate(tooFast), false);

      expect(NutritionUtils.getWeightChangeRateMessage(slow), contains('chậm'));
      expect(NutritionUtils.getWeightChangeRateMessage(moderate), contains('bền vững'));
      expect(NutritionUtils.getWeightChangeRateMessage(fast), contains('lý tưởng'));
      expect(NutritionUtils.getWeightChangeRateMessage(tooFast), contains('quá nhanh'));
    });

    test('calculateWeightChangePercentage', () {
      final pct = NutritionUtils.calculateWeightChangePercentage(80, 72);
      expect(pct, closeTo(-10.0, 0.0001));
    });
  });

  group('NutritionUtils summary and warnings', () {
    test('generateGoalSummary reflects lose/gain and days', () {
      final lose = UserNutritionInfo(
        age: 25,
        gender: 'Nam',
        heightCm: 175,
        currentWeightKg: 80,
        targetWeightKg: 75,
        activityLevel: 'Ít vận động',
      );
      final gain = UserNutritionInfo(
        age: 25,
        gender: 'Nữ',
        heightCm: 160,
        currentWeightKg: 45,
        targetWeightKg: 50,
        activityLevel: 'Ít vận động',
      );
      expect(NutritionUtils.generateGoalSummary(lose, 35), contains('giảm'));
      expect(NutritionUtils.generateGoalSummary(gain, 21), contains('tăng'));
    });

    test('needsWarning true if unhealthy or has message', () {
      final calcHealthy = NutritionCalculation(
        bmr: 1,
        tdee: 2000,
        caloriesMax: 3000,
        caloriesMin: 1500,
        weightDifference: 5,
        totalCaloriesNeeded: 1000,
        dailyCaloriesAdjustment: 200,
        targetCalories: 2000,
        targetDays: 7,
        isHealthy: true,
        warningMessage: null,
      );
      expect(NutritionUtils.needsWarning(calcHealthy), false);

      final calcWarn = NutritionCalculation(
        bmr: 1,
        tdee: 2000,
        caloriesMax: 3000,
        caloriesMin: 1500,
        weightDifference: 5,
        totalCaloriesNeeded: 1000,
        dailyCaloriesAdjustment: 1200,
        targetCalories: 4000,
        targetDays: 7,
        isHealthy: false,
        warningMessage: 'warn',
      );
      expect(NutritionUtils.needsWarning(calcWarn), true);
    });

    test('getSafetyColor and getSafetyIcon thresholds', () {
      expect(NutritionUtils.getSafetyColor(95), 0xFF10B981);
      expect(NutritionUtils.getSafetyColor(75), 0xFFF59E0B);
      expect(NutritionUtils.getSafetyColor(50), 0xFFEF4444);

      expect(NutritionUtils.getSafetyIcon(95), '✅');
      expect(NutritionUtils.getSafetyIcon(75), '⚠️');
      expect(NutritionUtils.getSafetyIcon(50), '❌');
    });

    test('distributeMealCalories sums to total', () {
      final map = NutritionUtils.distributeMealCalories(2000);
      final sum = map.values.reduce((a, b) => a + b);
      expect(sum, closeTo(2000, 0.0001));
      expect(map['breakfast']! > 0 && map['snacks']! > 0, true);
    });

    test('generate tips based on calculation and userInfo', () {
      final calcLose = NutritionCalculation(
        bmr: 1,
        tdee: 2200,
        caloriesMax: 3200,
        caloriesMin: 1500,
        weightDifference: 5,
        totalCaloriesNeeded: 1,
        dailyCaloriesAdjustment: 100,
        targetCalories: 1800,
        targetDays: 7,
        isHealthy: true,
        warningMessage: null,
      );
      final tipsLose = NutritionUtils.generateDietTips(calcLose);
      expect(tipsLose, isNotEmpty);

      final calcGain = NutritionCalculation(
        bmr: 1,
        tdee: 2200,
        caloriesMax: 3200,
        caloriesMin: 1500,
        weightDifference: 5,
        totalCaloriesNeeded: 1,
        dailyCaloriesAdjustment: 100,
        targetCalories: 2600,
        targetDays: 7,
        isHealthy: true,
        warningMessage: null,
      );
      final tipsGain = NutritionUtils.generateDietTips(calcGain);
      expect(tipsGain, isNotEmpty);

      final userLose = UserNutritionInfo(
        age: 25,
        gender: 'Nam',
        heightCm: 175,
        currentWeightKg: 80,
        targetWeightKg: 75,
        activityLevel: 'Ít vận động',
      );
      final userGain = UserNutritionInfo(
        age: 25,
        gender: 'Nữ',
        heightCm: 160,
        currentWeightKg: 45,
        targetWeightKg: 50,
        activityLevel: 'Ít vận động',
      );
      expect(NutritionUtils.generateExerciseTips(userLose), isNotEmpty);
      expect(NutritionUtils.generateExerciseTips(userGain), isNotEmpty);
    });
  });
}

