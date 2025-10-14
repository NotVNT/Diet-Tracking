class FoodRecordEntity {
  final String? id;
  final String foodName;
  final double calories;
  final DateTime date;
  // Optional extra info parsed from bot message
  final String? reason; // Lý do chọn
  final String? nutritionDetails; // Khối "Thông tin dinh dưỡng" (raw text)

  FoodRecordEntity({
    this.id,
    required this.foodName,
    required this.calories,
    required this.date,
    this.reason,
    this.nutritionDetails,
  });
}
