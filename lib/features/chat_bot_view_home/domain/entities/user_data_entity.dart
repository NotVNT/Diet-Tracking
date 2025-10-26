/// Domain entity for user data used in chat
class UserDataEntity {
  final int age;
  final double height;
  final double weight;
  final double? goalWeightKg;
  final String disease;
  final String allergy;
  final String goal;

  const UserDataEntity({
    required this.age,
    required this.height,
    required this.weight,
    this.goalWeightKg,
    required this.disease,
    required this.allergy,
    required this.goal,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserDataEntity &&
        other.age == age &&
        other.height == height &&
        other.weight == weight &&
        other.goalWeightKg == goalWeightKg &&
        other.disease == disease &&
        other.allergy == allergy &&
        other.goal == goal;
  }

  @override
  int get hashCode {
    return age.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        (goalWeightKg?.hashCode ?? 0) ^
        disease.hashCode ^
        allergy.hashCode ^
        goal.hashCode;
  }

  @override
  String toString() {
    return 'UserDataEntity(age: $age, height: $height, weight: $weight, goalWeightKg: $goalWeightKg, disease: $disease, allergy: $allergy, goal: $goal)';
  }
}
