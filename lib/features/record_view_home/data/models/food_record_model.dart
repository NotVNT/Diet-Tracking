import '../../domain/entities/food_record_entity.dart';

class FoodRecordModel extends FoodRecordEntity {
  FoodRecordModel({
    super.id,
    required super.foodName,
    required super.calories,
    required super.date,
    super.reason,
    super.nutritionDetails,
  });

  factory FoodRecordModel.fromJson(Map<String, dynamic> json) {
    return FoodRecordModel(
      id: json['id'],
      foodName: json['foodName'],
      calories: (json['calories'] as num).toDouble(),
      date: DateTime.parse(json['date']),
      reason: json['reason'],
      nutritionDetails: json['nutritionDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'date': date.toIso8601String(),
      if (reason != null) 'reason': reason,
      if (nutritionDetails != null) 'nutritionDetails': nutritionDetails,
    };
  }

  factory FoodRecordModel.fromEntity(FoodRecordEntity entity) {
    return FoodRecordModel(
      id: entity.id,
      foodName: entity.foodName,
      calories: entity.calories,
      date: entity.date,
      reason: entity.reason,
      nutritionDetails: entity.nutritionDetails,
    );
  }
}
