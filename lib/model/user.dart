// User domain model moved to a single place for onboarding and app-wide use.
// You can extend this as more onboarding steps are added.

class User {
  final String? uid;
  final String? email;
  final String? name;
  final GenderType? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final GoalType? goal;
  final String? allergies;
  final String? medicalConditions;
  final bool? isOnboardingCompleted;

  const User({
    this.uid,
    this.email,
    this.name,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
    this.allergies,
    this.medicalConditions,
    this.isOnboardingCompleted,
  });

  User copyWith({
    String? uid,
    String? email,
    String? name,
    GenderType? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    GoalType? goal,
    String? allergies,
    String? medicalConditions,
    bool? isOnboardingCompleted,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      allergies: allergies ?? this.allergies,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      isOnboardingCompleted:
          isOnboardingCompleted ?? this.isOnboardingCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'gender': gender?.name,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel?.name,
      'goal': goal?.name,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'isOnboardingCompleted': isOnboardingCompleted,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      gender: _tryParseGender(json['gender'] as String?),
      age: json['age'] as int?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: _tryParseActivity(json['activityLevel'] as String?),
      goal: _tryParseGoal(json['goal'] as String?),
      allergies: json['allergies'] as String?,
      medicalConditions: json['medicalConditions'] as String?,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool?,
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
