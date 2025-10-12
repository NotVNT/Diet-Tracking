import '../../domain/entities/user_data_entity.dart';

/// Data model for user data with Firebase document parsing
class UserDataModel extends UserDataEntity {
  const UserDataModel({
    required super.age,
    required super.height,
    required super.weight,
    required super.disease,
    required super.allergy,
    required super.goal,
  });

  /// Creates UserDataModel from Firebase document data
  factory UserDataModel.fromFirebaseData(Map<String, dynamic> userData) {
    final bodyInfo = userData["bodyInfo"] as Map<String, dynamic>? ?? {};
    final diseaseList = bodyInfo["medicalConditions"] as List<dynamic>? ?? [];
    final allergyList = bodyInfo["allergies"] as List<dynamic>? ?? [];

    return UserDataModel(
      age: userData["age"] ?? 18,
      height: (bodyInfo["heightCm"] ?? 170).toDouble(),
      weight: (bodyInfo["weightKg"] ?? 65).toDouble(),
      disease: diseaseList.join(', '),
      allergy: allergyList.join(', '),
      goal: userData["goalWeightKg"]?.toString() ?? "",
    );
  }

  /// Creates UserDataModel from entity
  factory UserDataModel.fromEntity(UserDataEntity entity) {
    return UserDataModel(
      age: entity.age,
      height: entity.height,
      weight: entity.weight,
      disease: entity.disease,
      allergy: entity.allergy,
      goal: entity.goal,
    );
  }

  /// Converts to API request body format
  Map<String, dynamic> toApiBody(String prompt) {
    return {
      "age": age,
      "height": height,
      "weight": weight,
      "disease": disease,
      "allergy": allergy,
      "goal": goal,
      "prompt": prompt,
    };
  }

  /// Converts model to entity
  UserDataEntity toEntity() {
    return UserDataEntity(
      age: age,
      height: height,
      weight: weight,
      disease: disease,
      allergy: allergy,
      goal: goal,
    );
  }

  @override
  String toString() {
    return 'UserDataModel(age: $age, height: $height, weight: $weight, disease: $disease, allergy: $allergy, goal: $goal)';
  }
}
