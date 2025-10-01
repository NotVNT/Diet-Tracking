import 'body_info_model.dart';

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
  final BodyInfoModel? bodyInfo;
  final ActivityLevel? activityLevel;
  final List<String>? goals;
  final String? avatarUrl;

  const User({
    this.uid,
    this.email,
    this.fullName,
    this.phone,
    this.birthDate,
    this.gender,
    this.age,
    this.bodyInfo,
    this.activityLevel,
    this.goals,
    this.avatarUrl,
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
    BodyInfoModel? bodyInfo,
    ActivityLevel? activityLevel,
    List<String>? goals,
    String? avatarUrl,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bodyInfo: bodyInfo ?? this.bodyInfo,
      activityLevel: activityLevel ?? this.activityLevel,
      goals: goals ?? this.goals,
      avatarUrl: avatarUrl ?? this.avatarUrl,
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
      'bodyInfo': bodyInfo?.toJson(),
      'activityLevel': activityLevel?.name,
      'goal': goals,
      'avatarUrl': avatarUrl,
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
      bodyInfo: json['bodyInfo'] != null
          ? BodyInfoModel.fromJson(json['bodyInfo'] as Map<String, dynamic>)
          : null,
      activityLevel: _tryParseActivity(json['activityLevel'] as String?),
      goals: _parseStringList(json['goal']),
      avatarUrl: json['avatarUrl'] as String?,
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
  // Fallback: store single toString
  final s = value.toString();
  return s.isEmpty ? null : [s];
}
