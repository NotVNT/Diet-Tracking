import '../model/nutrition_calculation_model.dart';
import '../services/nutrition_calculator_service.dart';

/// Các hàm tiện ích cho tính toán dinh dưỡng
class NutritionUtils {
  /// Chuyển đổi mức độ vận động sang hệ số
  static double getActivityMultiplier(String activityLevel) {
    return NutritionCalculatorService.activityMultipliers[activityLevel] ?? 1.2;
  }

  /// Lấy tên mức độ vận động từ hệ số
  static String getActivityLevelName(double multiplier) {
    for (var entry
        in NutritionCalculatorService.activityMultipliers.entries) {
      if (entry.value == multiplier) {
        return entry.key;
      }
    }
    return 'Ít vận động';
  }

  /// Format calories thành chuỗi dễ đọc
  static String formatCalories(double calories) {
    return '${calories.toStringAsFixed(0)} cal';
  }

  /// Format cân nặng thành chuỗi dễ đọc
  static String formatWeight(double weight) {
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Format số ngày thành chuỗi dễ đọc
  static String formatDays(int days) {
    if (days < 7) {
      return '$days ngày';
    } else if (days < 30) {
      final weeks = (days / 7).toStringAsFixed(1);
      return '$days ngày (≈ $weeks tuần)';
    } else if (days < 365) {
      final months = (days / 30).toStringAsFixed(1);
      return '$days ngày (≈ $months tháng)';
    } else {
      final years = (days / 365).toStringAsFixed(1);
      return '$days ngày (≈ $years năm)';
    }
  }

  /// Kiểm tra xem giới tính có hợp lệ không
  static bool isValidGender(String gender) {
    final normalized = gender.toLowerCase();
    return normalized == 'nam' ||
        normalized == 'male' ||
        normalized == 'nữ' ||
        normalized == 'female';
  }

  /// Chuẩn hóa giới tính
  static String normalizeGender(String gender) {
    final normalized = gender.toLowerCase();
    if (normalized == 'male') return 'Nam';
    if (normalized == 'female') return 'Nữ';
    return gender;
  }

  /// Tính BMI (Body Mass Index)
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  /// Phân loại BMI
  static String classifyBMI(double bmi) {
    if (bmi < 18.5) {
      return 'Thiếu cân';
    } else if (bmi < 25) {
      return 'Bình thường';
    } else if (bmi < 30) {
      return 'Thừa cân';
    } else {
      return 'Béo phì';
    }
  }

  /// Tính cân nặng lý tưởng dựa trên chiều cao (công thức Devine)
  static double calculateIdealWeight(double heightCm, String gender) {
    final heightInches = heightCm / 2.54;
    final baseHeight = 60.0; // 5 feet

    if (gender.toLowerCase() == 'nam' || gender.toLowerCase() == 'male') {
      // Nam: 50 kg + 2.3 kg cho mỗi inch trên 5 feet
      return 50 + 2.3 * (heightInches - baseHeight);
    } else {
      // Nữ: 45.5 kg + 2.3 kg cho mỗi inch trên 5 feet
      return 45.5 + 2.3 * (heightInches - baseHeight);
    }
  }

  /// Tính số calories cần thiết để thay đổi cân nặng
  static double calculateCaloriesForWeightChange(double weightChangeKg) {
    return weightChangeKg.abs() *
        NutritionCalculatorService.caloriesPerKg;
  }

  /// Tính tốc độ thay đổi cân nặng (kg/tuần)
  static double calculateWeightChangeRate(double weightChangeKg, int days) {
    final weeks = days / 7;
    return weightChangeKg / weeks;
  }

  /// Kiểm tra tốc độ thay đổi cân nặng có an toàn không
  static bool isSafeWeightChangeRate(double weightChangeRate) {
    // An toàn: 0.5-1 kg/tuần
    return weightChangeRate.abs() >= 0.25 && weightChangeRate.abs() <= 1.0;
  }

  /// Lấy thông báo về tốc độ thay đổi cân nặng
  static String getWeightChangeRateMessage(double weightChangeRate) {
    final rate = weightChangeRate.abs();
    if (rate < 0.25) {
      return 'Tốc độ thay đổi rất chậm - có thể mất động lực';
    } else if (rate <= 0.5) {
      return 'Tốc độ thay đổi chậm nhưng bền vững';
    } else if (rate <= 1.0) {
      return 'Tốc độ thay đổi lý tưởng và an toàn';
    } else if (rate <= 1.5) {
      return 'Tốc độ thay đổi hơi nhanh - cần theo dõi';
    } else {
      return 'Tốc độ thay đổi quá nhanh - không an toàn';
    }
  }

  /// Tính phần trăm thay đổi cân nặng
  static double calculateWeightChangePercentage(
    double currentWeight,
    double targetWeight,
  ) {
    return ((targetWeight - currentWeight) / currentWeight) * 100;
  }

  /// Tạo thông báo tóm tắt mục tiêu
  static String generateGoalSummary(UserNutritionInfo userInfo, int targetDays) {
    final action = userInfo.isLosingWeight ? 'giảm' : 'tăng';
    final weight = userInfo.weightDifference.toStringAsFixed(1);
    final weeks = (targetDays / 7).toStringAsFixed(1);
    
    return 'Bạn muốn $action $weight kg trong $targetDays ngày (≈ $weeks tuần)';
  }

  /// Kiểm tra xem có cần cảnh báo không
  static bool needsWarning(NutritionCalculation calculation) {
    return !calculation.isHealthy || calculation.warningMessage != null;
  }

  /// Lấy màu sắc cho mức độ an toàn
  static int getSafetyColor(double safetyLevel) {
    if (safetyLevel >= 90) {
      return 0xFF10B981; // Green
    } else if (safetyLevel >= 70) {
      return 0xFFF59E0B; // Yellow
    } else {
      return 0xFFEF4444; // Red
    }
  }

  /// Lấy icon cho mức độ an toàn
  static String getSafetyIcon(double safetyLevel) {
    if (safetyLevel >= 90) {
      return '✅';
    } else if (safetyLevel >= 70) {
      return '⚠️';
    } else {
      return '❌';
    }
  }

  /// Tính số calories cần thiết cho từng bữa ăn (phân bổ)
  static Map<String, double> distributeMealCalories(double totalCalories) {
    return {
      'breakfast': totalCalories * 0.30, // 30% cho bữa sáng
      'lunch': totalCalories * 0.40, // 40% cho bữa trưa
      'dinner': totalCalories * 0.25, // 25% cho bữa tối
      'snacks': totalCalories * 0.05, // 5% cho snacks
    };
  }

  /// Tạo gợi ý về chế độ ăn
  static List<String> generateDietTips(NutritionCalculation calculation) {
    final tips = <String>[];

    if (calculation.targetCalories < calculation.tdee) {
      // Giảm cân
      tips.add('Ăn nhiều rau xanh và protein để no lâu');
      tips.add('Uống đủ nước (2-3 lít/ngày)');
      tips.add('Tránh đồ ăn chế biến sẵn và đồ ngọt');
      tips.add('Ăn chậm và nhai kỹ');
    } else {
      // Tăng cân
      tips.add('Ăn nhiều bữa nhỏ trong ngày');
      tips.add('Tăng protein và carbs lành mạnh');
      tips.add('Uống sữa và smoothie giàu calories');
      tips.add('Tập luyện để tăng cơ, không chỉ mỡ');
    }

    return tips;
  }

  /// Tạo gợi ý về tập luyện
  static List<String> generateExerciseTips(UserNutritionInfo userInfo) {
    final tips = <String>[];

    if (userInfo.isLosingWeight) {
      tips.add('Cardio 30-45 phút, 4-5 lần/tuần');
      tips.add('Kết hợp tập tạ để giữ cơ bắp');
      tips.add('Đi bộ sau bữa ăn');
    } else {
      tips.add('Tập tạ nặng, 4-5 lần/tuần');
      tips.add('Giảm cardio, tập trung vào sức mạnh');
      tips.add('Nghỉ ngơi đầy đủ để cơ phục hồi');
    }

    return tips;
  }
}

