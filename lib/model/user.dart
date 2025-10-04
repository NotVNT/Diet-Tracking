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
}

enum GenderType { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

GenderType? _tryParseGender(String? value) {
  if (value == null) return null;
  return GenderType.values.firstWhere(
    (e) => e.name == value,
    orElse: () => GenderType.other,
  );
}

// Removed parsing activity level since it's no longer stored

// Removed parseStringList helper for goals (no longer stored)
