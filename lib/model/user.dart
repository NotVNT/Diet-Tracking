import 'body_info_model.dart';

/// User domain model for diet tracking application
/// Contains user profile information and preferences
class User {
  final String? uid;
  final String? email;
  final String? fullName;
  final String? phone;
  final GenderType? gender;
  final int? age;
  final BodyInfoModel? bodyInfo;
  final String? goal;
  // Removed avatarUrl from Firestore persistence

  const User({
    this.uid,
    this.email,
    this.fullName,
    this.phone,
    this.gender,
    this.age,
    this.bodyInfo,
    this.goal,
  });

  /// Creates a copy of this user with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    GenderType? gender,
    int? age,
    BodyInfoModel? bodyInfo,
    String? goal,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      bodyInfo: bodyInfo ?? this.bodyInfo,
      goal: goal ?? this.goal,
    );
  }

  /// Converts user to JSON for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'emailLowercase': email?.toLowerCase(),
      'fullName': fullName,
      'phone': phone,
      'gender': gender?.name,
      'age': age,
      'bodyInfo': bodyInfo?.toJson(),
      'goal': goal,
    };
  }

  /// Creates user from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      gender: _tryParseGender(json['gender'] as String?),
      age: json['age'] as int?,
      bodyInfo: json['bodyInfo'] != null
          ? BodyInfoModel.fromJson(json['bodyInfo'] as Map<String, dynamic>)
          : null,
      goal: json['goal'] as String?,
    );
  }

  /// Creates a User object from guest data collected during onboarding
  factory User.fromGuestData(Map<String, dynamic> data) {
    return User(
      // Guest users don't have these fields until proper registration
      uid: '', // Will be set by Firestore later
      email: '',
      fullName: 'Guest',
      phone: '',
      age: data['age'] as int?,
      gender: _tryParseGender(data['gender'] as String?),
      goal: data['goal'] as String?,
      bodyInfo: BodyInfoModel(
        heightCm: data['heightCm'] as double?,
        weightKg: data['weightKg'] as double?,
        goalWeightKg: data['goalWeightKg'] as double?,
        activityLevel: data['activityLevel'] as String?,
        medicalConditions: (data['medicalConditions'] as List?)?.cast<String>(),
        allergies: (data['allergies'] as List?)?.cast<String>(),
      ),
    );
  }
}

enum GenderType { male, female, other }

GenderType? _tryParseGender(String? value) {
  if (value == null) return null;
  try {
    return GenderType.values.firstWhere((e) => e.name == value);
  } catch (_) {
    return GenderType.other;
  }
}

// Removed parsing activity level since it's no longer stored

// Removed parseStringList helper for goals (no longer stored)
