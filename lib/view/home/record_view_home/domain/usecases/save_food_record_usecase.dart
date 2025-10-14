import '../entities/food_record_entity.dart';
import '../repositories/food_record_repository.dart';

class SaveFoodRecordUseCase {
  final FoodRecordRepository _repository;

  SaveFoodRecordUseCase(this._repository);

  Future<void> call(
    String foodName,
    double calories, {
    String? reason,
    String? nutritionDetails,
  }) async {
    final foodRecord = FoodRecordEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodName,
      calories: calories,
      date: DateTime.now(),
      reason: reason,
      nutritionDetails: nutritionDetails,
    );

    await _repository.saveFoodRecord(foodRecord);
  }
}
