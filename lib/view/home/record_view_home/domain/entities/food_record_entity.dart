class FoodRecordEntity {
  final String? id;
  final String foodName;
  final double calories;
  final DateTime date;

  FoodRecordEntity({
    this.id,
    required this.foodName,
    required this.calories,
    required this.date,
  });
}

