/// Model để lưu trữ kết quả tính toán dinh dưỡng
class NutritionCalculation {
  final double bmr; // Basal Metabolic Rate
  final double tdee; // Total Daily Energy Expenditure
  final double caloriesMax; // Calories tối đa
  final double caloriesMin; // Calories tối thiểu
  final double weightDifference; // Chênh lệch cân nặng (kg)
  final double totalCaloriesNeeded; // Tổng calories cần thiết
  final double dailyCaloriesAdjustment; // Calories điều chỉnh mỗi ngày
  final double targetCalories; // Calories mục tiêu
  final int targetDays; // Số ngày mục tiêu
  final bool isHealthy; // Có phù hợp với sức khỏe không
  final String? warningMessage; // Thông báo cảnh báo nếu có

  NutritionCalculation({
    required this.bmr,
    required this.tdee,
    required this.caloriesMax,
    required this.caloriesMin,
    required this.weightDifference,
    required this.totalCaloriesNeeded,
    required this.dailyCaloriesAdjustment,
    required this.targetCalories,
    required this.targetDays,
    required this.isHealthy,
    this.warningMessage,
  });

  /// Kiểm tra xem calories mục tiêu có nằm trong khoảng an toàn không
  bool get isCaloriesInSafeRange {
    return targetCalories >= caloriesMin && targetCalories <= caloriesMax;
  }

  /// Lấy mức độ an toàn (0-100%)
  double get safetyLevel {
    if (targetCalories < caloriesMin) {
      return (targetCalories / caloriesMin) * 100;
    } else if (targetCalories > caloriesMax) {
      return (caloriesMax / targetCalories) * 100;
    }
    return 100.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'bmr': bmr,
      'tdee': tdee,
      'caloriesMax': caloriesMax,
      'caloriesMin': caloriesMin,
      'weightDifference': weightDifference,
      'totalCaloriesNeeded': totalCaloriesNeeded,
      'dailyCaloriesAdjustment': dailyCaloriesAdjustment,
      'targetCalories': targetCalories,
      'targetDays': targetDays,
      'isHealthy': isHealthy,
      'warningMessage': warningMessage,
    };
  }

  factory NutritionCalculation.fromJson(Map<String, dynamic> json) {
    return NutritionCalculation(
      bmr: (json['bmr'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
      caloriesMax: (json['caloriesMax'] as num).toDouble(),
      caloriesMin: (json['caloriesMin'] as num).toDouble(),
      weightDifference: (json['weightDifference'] as num).toDouble(),
      totalCaloriesNeeded: (json['totalCaloriesNeeded'] as num).toDouble(),
      dailyCaloriesAdjustment: (json['dailyCaloriesAdjustment'] as num)
          .toDouble(),
      targetCalories: (json['targetCalories'] as num).toDouble(),
      targetDays: json['targetDays'] as int,
      isHealthy: json['isHealthy'] as bool,
      warningMessage: json['warningMessage'] as String?,
    );
  }

  @override
  String toString() {
    return '''NutritionCalculation {
      bmr: $bmr,
      tdee: $tdee,
      caloriesMax: $caloriesMax,
      caloriesMin: $caloriesMin,
      weightDifference: $weightDifference,
      totalCaloriesNeeded: $totalCaloriesNeeded,
      dailyCaloriesAdjustment: $dailyCaloriesAdjustment,
      targetCalories: $targetCalories,
      targetDays: $targetDays,
      isHealthy: $isHealthy,
      warningMessage: $warningMessage
    }''';
  }
}

/// Model để lưu thông tin người dùng cần thiết cho tính toán
class UserNutritionInfo {
  final int age;
  final String gender; // 'Nam' hoặc 'Nữ'
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final String activityLevel;

  UserNutritionInfo({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.activityLevel,
  });

  /// Kiểm tra xem có đang muốn giảm cân không
  bool get isLosingWeight => currentWeightKg > targetWeightKg;

  /// Kiểm tra xem có đang muốn tăng cân không
  bool get isGainingWeight => currentWeightKg < targetWeightKg;

  /// Kiểm tra xem có đang muốn duy trì cân nặng không
  bool get isMaintainingWeight => currentWeightKg == targetWeightKg;

  /// Lấy chênh lệch cân nặng (giá trị tuyệt đối)
  double get weightDifference => (currentWeightKg - targetWeightKg).abs();

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'currentWeightKg': currentWeightKg,
      'targetWeightKg': targetWeightKg,
      'activityLevel': activityLevel,
    };
  }

  factory UserNutritionInfo.fromJson(Map<String, dynamic> json) {
    return UserNutritionInfo(
      age: json['age'] as int,
      gender: json['gender'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      currentWeightKg: (json['currentWeightKg'] as num).toDouble(),
      targetWeightKg: (json['targetWeightKg'] as num).toDouble(),
      activityLevel: json['activityLevel'] as String,
    );
  }
}
