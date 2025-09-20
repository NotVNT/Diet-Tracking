/// User domain model for diet tracking application
/// Contains user profile information and preferences
class User {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? phone;
  final DateTime? birthDate;
  final GenderType? gender;
  final int? age;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activityLevel;
  final GoalType? goal;

  const User({
    this.uid,
    this.email,
    this.fullName,
    this.phone,
    this.birthDate,
    this.gender,
    this.age,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goal,
  });

  /// Creates a copy of this user with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    DateTime? birthDate,
    GenderType? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    GoalType? goal,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
    );
  }

  /// Converts user to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'gender': gender?.name,
      'age': age,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'activityLevel': activityLevel?.name,
      'goal': goal?.name,
    };
  }

  /// Creates user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['birthDate'] as int)
          : null,
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
