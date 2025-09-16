// User domain model moved to a single place for onboarding and app-wide use.
// You can extend this as more onboarding steps are added.

class User {
  final GenderType? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final GoalType? goal;

  const User({
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
  });

  User copyWith({
    GenderType? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    GoalType? goal,
  }) {
    return User(
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender?.name,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel?.name,
      'goal': goal?.name,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      gender: _tryParseGender(json['gender'] as String?),
      age: json['age'] as int?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: _tryParseActivity(json['activityLevel'] as String?),
      goal: _tryParseGoal(json['goal'] as String?),
    );
  }
}

enum GenderType { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum GoalType { loseWeight, maintain, gainWeight }

GenderType? _tryParseGender(String? value) {
  if (value == null) return null;
  return GenderType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GenderType.other,
  );
}

ActivityLevel? _tryParseActivity(String? value) {
  if (value == null) return null;
  try {
    return ActivityLevel.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return null;
  }
}

GoalType? _tryParseGoal(String? value) {
  if (value == null) return null;
  try {
    return GoalType.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return null;
  }
}
