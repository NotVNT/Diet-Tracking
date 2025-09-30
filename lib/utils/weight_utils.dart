import 'dart:math';

/// Utilities for weight conversions and BMI calculation
class WeightUtils {
  /// Convert kilograms to pounds
  static double kgToLb(double kg) => kg * 2.2046226218;

  /// Convert pounds to kilograms
  static double lbToKg(double lb) => lb / 2.2046226218;

  /// Round to a desired step (e.g. 0.5 kg)
  static double roundToStep(double value, double step) {
    final scaled = value / step;
    // Add a tiny, sign-aware epsilon to mitigate floating-point artifacts
    final adjusted = scaled + (scaled >= 0 ? 1e-9 : -1e-9);
    return adjusted.roundToDouble() * step;
  }

  /// Calculate BMI from kg and height cm
  static double calculateBmi({
    required double weightKg,
    required double heightCm,
  }) {
    if (weightKg <= 0 || heightCm <= 0) return 0;
    final h = heightCm / 100.0;
    return weightKg / pow(h, 2);
  }

  /// Vietnamese description for BMI category
  static String bmiDescription(double bmi) {
    if (bmi <= 0) return '—';
    if (bmi < 18.5) return 'Bạn đang thiếu cân';
    if (bmi < 25) return 'Bạn có cân nặng bình thường';
    if (bmi < 30) return 'Bạn đang thừa cân';
    if (bmi < 35) return 'Bạn béo phì (độ I)';
    if (bmi < 40) return 'Bạn béo phì (độ II)';
    return 'Bạn cần giảm cân nghiêm túc để bảo vệ sức khỏe';
  }
}
