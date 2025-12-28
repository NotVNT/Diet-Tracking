import '../../domain/entities/user_data_entity.dart';

/// Data model for user data with Firebase document parsing (STRICT schema)
class UserDataModel extends UserDataEntity {
  const UserDataModel({
    required super.age,
    required super.height,
    required super.weight,
    super.goalWeightKg,
    required super.disease,
    required super.allergy,
    required super.goal,
    super.gender,
  });

  /// Creates UserDataModel from Firebase document data (STRICT)
  /// Firestore document MUST follow this schema exactly:
  /// {
  ///   "age": int,
  ///   "goal": string,
  ///   "bodyInfo": {
  ///     "heightCm": int,
  ///     "weightKg": int,
  ///     "allergies": List&lt;String&gt;
  ///   }
  /// }
  factory UserDataModel.fromFirebaseData(Map<String, dynamic> userData) {
    T requireType<T>(Object? value, String field) {
      if (value is T) return value;
      throw FormatException(
        'Invalid type for "$field". Expected $T, got ${value.runtimeType}',
      );
    }

    // age
    final num ageNum = requireType<num>(userData['age'], 'age');
    final int age = ageNum.toInt();

    // goal
    final String goal = (requireType<String>(userData['goal'], 'goal')).trim();
    if (goal.isEmpty) {
      throw const FormatException('Field "goal" must be a non-empty string');
    }

    // gender (optional)
    final String? gender = userData['gender'] as String?;

    // bodyInfo
    final Map<String, dynamic> bodyInfo = requireType<Map<String, dynamic>>(
      userData['bodyInfo'],
      'bodyInfo',
    );

    // heightCm, weightKg, goalWeightKg (goalWeightKg có thể thiếu -> null)
    final num heightNum = requireType<num>(
      bodyInfo['heightCm'],
      'bodyInfo.heightCm',
    );
    final num weightNum = requireType<num>(
      bodyInfo['weightKg'],
      'bodyInfo.weightKg',
    );

    final double height = heightNum.toDouble();
    final double weight = weightNum.toDouble();

    // goalWeightKg: optional on Firestore
    final dynamic goalWRaw = bodyInfo['goalWeightKg'];
    final double? goalWeightKg = goalWRaw == null
        ? null
        : (goalWRaw is num)
        ? goalWRaw.toDouble()
        : double.tryParse(goalWRaw.toString());

    // allergies (allow null -> empty list)
    final dynamic allergyDyn = bodyInfo['allergies'];
    final List<String> allergies;
    if (allergyDyn == null) {
      allergies = <String>[];
    } else if (allergyDyn is List) {
      if (!allergyDyn.every((e) => e is String)) {
        throw const FormatException('All items in bodyInfo.allergies must be String');
      }
      allergies = allergyDyn
          .cast<String>()
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      throw FormatException(
        'Invalid type for "bodyInfo.allergies". Expected List<String> or null, got ${allergyDyn.runtimeType}',
      );
    }

    // Basic range validations (optional but helpful)
    if (age < 0 || age > 120) {
      throw const FormatException('age out of range (0-120)');
    }
    if (height < 30 || height > 300) {
      throw const FormatException('bodyInfo.heightCm out of range (30-300)');
    }
    if (weight < 2 || weight > 500) {
      throw const FormatException('bodyInfo.weightKg out of range (2-500)');
    }

    // Join lists for model fields
    const String disease = ''; // medicalConditions no longer used
    final String allergy = allergies.join(', ');

    return UserDataModel(
      age: age,
      height: height,
      weight: weight,
      goalWeightKg: goalWeightKg,
      disease: disease,
      allergy: allergy,
      goal: goal,
      gender: gender,
    );
  }

  /// Creates UserDataModel from entity
  factory UserDataModel.fromEntity(UserDataEntity entity) {
    return UserDataModel(
      age: entity.age,
      height: entity.height,
      weight: entity.weight,
      goalWeightKg: entity.goalWeightKg,
      disease: entity.disease,
      allergy: entity.allergy,
      goal: entity.goal,
      gender: entity.gender,
    );
  }

  /// Converts to API request body format
  Map<String, dynamic> toApiBody(String prompt) {
    return {
      'age': age,
      'height': height,
      'weight': weight,
      'goal_weight': goalWeightKg ?? 0.0,
      'disease': disease.trim(),
      'allergy': allergy.trim(),
      'goal': goal.trim(),
      'prompt': prompt,
      'gender': gender,
    };
  }

  /// Converts model to entity
  UserDataEntity toEntity() {
    return UserDataEntity(
      age: age,
      height: height,
      weight: weight,
      goalWeightKg: goalWeightKg,
      disease: disease,
      allergy: allergy,
      goal: goal,
      gender: gender,
    );
  }

  @override
  String toString() {
    return 'UserDataModel(age: $age, height: $height, weight: $weight, goalWeightKg: $goalWeightKg, disease: $disease, allergy: $allergy, goal: $goal, gender: $gender)';
  }
}
