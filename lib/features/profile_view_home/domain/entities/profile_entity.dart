import '../../../../model/user.dart';

/// Domain entity for user profile information
class ProfileEntity {
  final String uid;
  final String displayName;
  final String email;
  final GenderType? gender;
  final int? age;
  final double? height;
  final double? weight;
  final double? goalWeight;
  final String? goal;
  final List<String>? medicalConditions;
  final List<String>? allergies;
  final String? avatars;

  const ProfileEntity({
    required this.uid,
    required this.displayName,
    required this.email,
    this.gender,
    this.age,
    this.height,
    this.weight,
    this.goalWeight,
    this.goal,
    this.medicalConditions,
    this.allergies,
    this.avatars,
  });

  /// Create ProfileEntity from User model
  factory ProfileEntity.fromUser(User user) {
    return ProfileEntity(
      uid: user.uid ?? '',
      displayName: user.fullName ?? '',
      email: user.email ?? '',
      gender: user.gender,
      age: user.age,
      height: user.bodyInfo?.heightCm,
      weight: user.bodyInfo?.weightKg,
      goalWeight: user.bodyInfo?.goalWeightKg,
      goal: user.goal,
      medicalConditions: user.bodyInfo?.medicalConditions,
      allergies: user.bodyInfo?.allergies,
      avatars: user.avatars,
    );
  }

  ProfileEntity copyWith({
    String? displayName,
    String? email,
    GenderType? gender,
    int? age,
    double? height,
    double? weight,
    double? goalWeight,
    String? goal,
    List<String>? medicalConditions,
    List<String>? allergies,
    String? avatars,
  }) {
    return ProfileEntity(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goalWeight: goalWeight ?? this.goalWeight,
      goal: goal ?? this.goal,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      avatars: avatars ?? this.avatars,
    );
  }
}
