enum RecordType { food, barcode, text } // Thêm enum để phân loại

class FoodRecordEntity {
  final String? id;
  final String foodName;
  final double calories;
  final DateTime date;
  final String? imagePath;
  final RecordType recordType;

  // Optional extra info parsed from bot message
  final String? reason; // Lý do chọn
  final String? nutritionDetails; // Khối "Thông tin dinh dưỡng" (raw text)
  final double? protein;
  final double? carbs;
  final double? fat;

  FoodRecordEntity({
    this.id,
    required this.foodName,
    required this.calories,
    required this.date,
    this.imagePath,
    this.recordType = RecordType.text, // Mặc định là text
    this.reason,
    this.nutritionDetails,
    this.protein,
    this.carbs,
    this.fat,
  });

  FoodRecordEntity copyWith({
    String? id,
    String? foodName,
    double? calories,
    DateTime? date,
    String? imagePath,
    RecordType? recordType,
    String? reason,
    String? nutritionDetails,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return FoodRecordEntity(
      id: id ?? this.id,
      foodName: foodName ?? this.foodName,
      calories: calories ?? this.calories,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      recordType: recordType ?? this.recordType,
      reason: reason ?? this.reason,
      nutritionDetails: nutritionDetails ?? this.nutritionDetails,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}
