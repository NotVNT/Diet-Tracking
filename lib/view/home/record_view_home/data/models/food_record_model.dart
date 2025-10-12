import '../../domain/entities/food_record_entity.dart';

class FoodRecordModel extends FoodRecordEntity {
  FoodRecordModel({
    super.id,
    required super.foodName,
    required super.calories,
    required super.date,
  });

  factory FoodRecordModel.fromJson(Map<String, dynamic> json) {
    return FoodRecordModel(
      id: json['id'],
      foodName: json['foodName'],
      calories: json['calories'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'date': date.toIso8601String(),
    };
  }

  factory FoodRecordModel.fromEntity(FoodRecordEntity entity) {
    return FoodRecordModel(
      id: entity.id,
      foodName: entity.foodName,
      calories: entity.calories,
      date: entity.date,
    );
  }
}
