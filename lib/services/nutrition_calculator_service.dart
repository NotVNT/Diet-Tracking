import '../model/nutrition_calculation_model.dart';

/// Service để tính toán các chỉ số dinh dưỡng
class NutritionCalculatorService {
  /// Hệ số mức độ vận động (Activity Level Multiplier)
  static const Map<String, double> activityMultipliers = {
    'Ít vận động': 1.2,
    'Vận động nhẹ': 1.375,
    'Vận động vừa': 1.55,
    'Vận động nặng': 1.725,
    'Vận động rất nặng': 1.9,
  };

  /// Số calories cần thiết để thay đổi 1kg cân nặng
  static const double caloriesPerKg = 7700.0;

  /// Calories tối thiểu cho nam
  static const double minCaloriesMale = 1500.0;

  /// Calories tối thiểu cho nữ
  static const double minCaloriesFemale = 1200.0;

  /// Số calories điều chỉnh tối đa mỗi ngày (an toàn)
  static const double maxDailyAdjustment = 1000.0;

  /// Tính BMR (Basal Metabolic Rate) theo công thức Mifflin-St Jeor
  ///
  /// Đối với nam: BMR = (10 × cân nặng) + (6.25 × chiều cao) - (5 × tuổi) + 5
  /// Đối với nữ: BMR = (10 × cân nặng) + (6.25 × chiều cao) - (5 × tuổi) - 161
  static double calculateBMR({
    required double weightKg,
    required double heightCm,
    required int age,
    required String gender,
  }) {
    final baseCalc = (10 * weightKg) + (6.25 * heightCm) - (5 * age);

    if (gender.toLowerCase() == 'nam' || gender.toLowerCase() == 'male') {
      return baseCalc + 5;
    } else {
      return baseCalc - 161;
    }
  }

  /// Tính TDEE (Total Daily Energy Expenditure)
  ///
  /// TDEE = BMR × hệ số mức độ vận động
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multiplier = activityMultipliers[activityLevel] ?? 1.2;
    return bmr * multiplier;
  }

  /// Lấy calories tối thiểu theo giới tính
  static double getMinCalories(String gender) {
    if (gender.toLowerCase() == 'nam' || gender.toLowerCase() == 'male') {
      return minCaloriesMale;
    } else {
      return minCaloriesFemale;
    }
  }

  /// Tính calories tối đa
  ///
  /// Calories tối đa = TDEE + 1000
  static double calculateMaxCalories(double tdee) {
    return tdee + 1000;
  }

  /// Tính toán đầy đủ các chỉ số dinh dưỡng
  static NutritionCalculation calculate({
    required UserNutritionInfo userInfo,
    required int targetDays,
  }) {
    // 1. Tính BMR
    final bmr = calculateBMR(
      weightKg: userInfo.currentWeightKg,
      heightCm: userInfo.heightCm,
      age: userInfo.age,
      gender: userInfo.gender,
    );

    // 2. Tính TDEE
    final tdee = calculateTDEE(bmr: bmr, activityLevel: userInfo.activityLevel);

    // 3. Tính calories tối thiểu và tối đa
    final caloriesMin = getMinCalories(userInfo.gender);
    final caloriesMax = calculateMaxCalories(tdee);

    // 4. Tính chênh lệch cân nặng
    final weightDifference = userInfo.currentWeightKg - userInfo.targetWeightKg;

    // 5. Tính tổng calories cần thiết
    final totalCaloriesNeeded = weightDifference.abs() * caloriesPerKg;

    // 6. Tính calories điều chỉnh mỗi ngày
    final dailyCaloriesAdjustment = totalCaloriesNeeded / targetDays;

    // 7. Tính calories mục tiêu
    // Nếu giảm cân: TDEE - điều chỉnh
    // Nếu tăng cân: TDEE + điều chỉnh
    final targetCalories = weightDifference > 0
        ? tdee - dailyCaloriesAdjustment
        : tdee + dailyCaloriesAdjustment;

    // 8. Kiểm tra tính an toàn
    final isHealthy = _checkHealthySafety(
      targetCalories: targetCalories,
      caloriesMin: caloriesMin,
      caloriesMax: caloriesMax,
      dailyAdjustment: dailyCaloriesAdjustment,
    );

    // 9. Tạo thông báo cảnh báo nếu cần
    final warningMessage = _generateWarningMessage(
      targetCalories: targetCalories,
      caloriesMin: caloriesMin,
      caloriesMax: caloriesMax,
      dailyAdjustment: dailyCaloriesAdjustment,
      isLosingWeight: weightDifference > 0,
    );

    return NutritionCalculation(
      bmr: bmr,
      tdee: tdee,
      caloriesMax: caloriesMax,
      caloriesMin: caloriesMin,
      weightDifference: weightDifference.abs(),
      totalCaloriesNeeded: totalCaloriesNeeded,
      dailyCaloriesAdjustment: dailyCaloriesAdjustment,
      targetCalories: targetCalories,
      targetDays: targetDays,
      isHealthy: isHealthy,
      warningMessage: warningMessage,
    );
  }

  /// Kiểm tra tính an toàn của chế độ ăn
  static bool _checkHealthySafety({
    required double targetCalories,
    required double caloriesMin,
    required double caloriesMax,
    required double dailyAdjustment,
  }) {
    // Kiểm tra calories mục tiêu có nằm trong khoảng an toàn
    if (targetCalories < caloriesMin || targetCalories > caloriesMax) {
      return false;
    }

    // Kiểm tra mức điều chỉnh mỗi ngày có quá cao không
    if (dailyAdjustment > maxDailyAdjustment) {
      return false;
    }

    return true;
  }

  /// Tạo thông báo cảnh báo
  static String? _generateWarningMessage({
    required double targetCalories,
    required double caloriesMin,
    required double caloriesMax,
    required double dailyAdjustment,
    required bool isLosingWeight,
  }) {
    final List<String> warnings = [];

    // Cảnh báo calories quá thấp
    if (targetCalories < caloriesMin) {
      final deficit = caloriesMin - targetCalories;
      warnings.add(
        'Lượng calories mục tiêu (${targetCalories.toStringAsFixed(0)}) thấp hơn mức tối thiểu an toàn (${caloriesMin.toStringAsFixed(0)}) ${deficit.toStringAsFixed(0)} calories.',
      );
    }

    // Cảnh báo calories quá cao
    if (targetCalories > caloriesMax) {
      final excess = targetCalories - caloriesMax;
      warnings.add(
        'Lượng calories mục tiêu (${targetCalories.toStringAsFixed(0)}) cao hơn mức tối đa an toàn (${caloriesMax.toStringAsFixed(0)}) ${excess.toStringAsFixed(0)} calories.',
      );
    }

    // Cảnh báo điều chỉnh quá nhanh
    if (dailyAdjustment > maxDailyAdjustment) {
      warnings.add(
        'Mức thay đổi ${isLosingWeight ? "giảm" : "tăng"} cân quá nhanh (${dailyAdjustment.toStringAsFixed(0)} calories/ngày). Khuyến nghị tối đa ${maxDailyAdjustment.toStringAsFixed(0)} calories/ngày.',
      );
    }

    return warnings.isEmpty ? null : warnings.join('\n\n');
  }

  /// Tính số ngày tối thiểu để đạt mục tiêu một cách an toàn
  static int calculateMinimumSafeDays({required UserNutritionInfo userInfo}) {
    final bmr = calculateBMR(
      weightKg: userInfo.currentWeightKg,
      heightCm: userInfo.heightCm,
      age: userInfo.age,
      gender: userInfo.gender,
    );

    final tdee = calculateTDEE(bmr: bmr, activityLevel: userInfo.activityLevel);

    final caloriesMin = getMinCalories(userInfo.gender);
    final caloriesMax = calculateMaxCalories(tdee);

    final weightDifference = userInfo.weightDifference;
    final totalCaloriesNeeded = weightDifference * caloriesPerKg;

    // Tính số ngày tối thiểu dựa trên mức điều chỉnh tối đa
    double maxSafeAdjustment;
    if (userInfo.isLosingWeight) {
      // Giảm cân: không được xuống dưới caloriesMin
      maxSafeAdjustment = (tdee - caloriesMin).clamp(0, maxDailyAdjustment);
    } else {
      // Tăng cân: không được vượt quá caloriesMax
      maxSafeAdjustment = (caloriesMax - tdee).clamp(0, maxDailyAdjustment);
    }

    if (maxSafeAdjustment <= 0) {
      return 999; // Không thể đạt mục tiêu một cách an toàn
    }

    final minDays = (totalCaloriesNeeded / maxSafeAdjustment).ceil();
    return minDays;
  }

  /// Tính số ngày khuyến nghị (an toàn và hiệu quả)
  static int calculateRecommendedDays({required UserNutritionInfo userInfo}) {
    final weightDifference = userInfo.weightDifference;

    // Khuyến nghị giảm/tăng 0.5kg mỗi tuần (an toàn)
    const recommendedWeeklyChange = 0.5; // kg
    final weeks = (weightDifference / recommendedWeeklyChange).ceil();
    return weeks * 7; // Chuyển sang ngày
  }
}
