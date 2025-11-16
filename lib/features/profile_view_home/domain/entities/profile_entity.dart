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
    );
  }
}
