/// Body information model for diet tracking application
/// Contains physical measurements and health goals
class BodyInfoModel {
  final double? heightCm;
  final double? weightKg;
  final double? goalWeightKg;
  final String? activityLevel;
  final HealthStatus? health;
  final List<String>? allergies; // dị ứng

  const BodyInfoModel({
    this.heightCm,
    this.weightKg,
    this.goalWeightKg,
    this.activityLevel,
    this.health,
    this.allergies,
  });

  /// Creates a copy of this body info with updated fields
  BodyInfoModel copyWith({
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    String? activityLevel,
    HealthStatus? health,
    List<String>? allergies,
  }) {
    return BodyInfoModel(
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goalWeightKg: goalWeightKg ?? this.goalWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      health: health ?? this.health,
      allergies: allergies ?? this.allergies,
    );
  }

  /// Converts body info to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goalWeightKg': goalWeightKg,
      'activityLevel': activityLevel,
      'allergies': allergies,
    };
  }

  /// Creates body info from JSON data
  factory BodyInfoModel.fromJson(Map<String, dynamic> json) {
    return BodyInfoModel(
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      goalWeightKg: (json['goalWeightKg'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      health: _tryParseHealth(json['health'] as String?),
      allergies: _parseStringList(json['allergies']),
    );
  }

  /// Calculates BMI (Body Mass Index)
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm! <= 0) {
      return null;
    }
    final heightInMeters = heightCm! / 100;
    return weightKg! / (heightInMeters * heightInMeters);
  }

  /// Gets BMI category
  BmiCategory? get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return null;

    if (bmiValue < 18.5) return BmiCategory.underweight;
    if (bmiValue < 25) return BmiCategory.normal;
    if (bmiValue < 30) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  // Height goal removed; only weight goal is tracked
}

/// Health status enumeration
enum HealthStatus { excellent, good, fair, poor, unknown }

/// BMI category enumeration
enum BmiCategory { underweight, normal, overweight, obese }

/// Helper function to parse health status from string
HealthStatus? _tryParseHealth(String? value) {
  if (value == null) return null;
  try {
    return HealthStatus.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return HealthStatus.unknown;
  }
}

List<String>? _parseStringList(dynamic value) {
  if (value == null) return null;
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  if (value is String) {
    final parts = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? null : parts;
  }
  final s = value.toString();
  return s.isEmpty ? null : [s];
}
