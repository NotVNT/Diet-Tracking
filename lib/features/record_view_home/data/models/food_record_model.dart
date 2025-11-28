import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/food_record_entity.dart';

class FoodRecordModel extends FoodRecordEntity {
  FoodRecordModel({
    super.id,
    required super.foodName,
    required super.calories,
    required super.date,
    super.imagePath,
    super.recordType,
    super.reason,
    super.nutritionDetails,
    super.protein,
    super.carbs,
    super.fat,
    super.barcode,
  });

  factory FoodRecordModel.fromJson(Map<String, dynamic> json) {
    RecordType recordType;
    if (json.containsKey('scanType')) {
      recordType = (json['scanType'] == 'barcode')
          ? RecordType.barcode
          : RecordType.food;
    } else if (json.containsKey('recordType')) {
      recordType = RecordType.values.firstWhere(
        (e) => e.name == json['recordType'],
        orElse: () => RecordType.text,
      );
    } else {
      recordType = RecordType.text;
    }

    return FoodRecordModel(
      id: json['id'] as String?,
      foodName: json['foodName'] as String? ?? 'Unnamed Food',
      calories: (json['calories'] as num? ?? 0).toDouble(),
      date: _parseDate(json['date'] ?? json['scanDate']),
      imagePath: json['imagePath'] as String?,
      recordType: recordType,
      reason: json['reason'] as String?,
      nutritionDetails:
          json['nutritionDetails'] as String? ?? json['description'] as String?,
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
      barcode: json['barcode'] as String?,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    }
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodName': foodName,
      'calories': calories,
      'date': Timestamp.fromDate(date),
      'imagePath': imagePath,
      'recordType': recordType.name,
      if (reason != null) 'reason': reason,
      if (nutritionDetails != null) 'nutritionDetails': nutritionDetails,
      if (protein != null) 'protein': protein,
      if (carbs != null) 'carbs': carbs,
      if (fat != null) 'fat': fat,
      if (barcode != null) 'barcode': barcode,
    };
  }

  factory FoodRecordModel.fromEntity(FoodRecordEntity entity) {
    return FoodRecordModel(
      id: entity.id,
      foodName: entity.foodName,
      calories: entity.calories,
      date: entity.date,
      imagePath: entity.imagePath,
      recordType: entity.recordType,
      reason: entity.reason,
      nutritionDetails: entity.nutritionDetails,
      protein: entity.protein,
      carbs: entity.carbs,
      fat: entity.fat,
      barcode: entity.barcode,
    );
  }
}
