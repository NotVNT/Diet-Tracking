import '../entities/food_record_entity.dart';
import '../repositories/food_record_repository.dart';

class SaveFoodRecordUseCase {
  final FoodRecordRepository _repository;

  SaveFoodRecordUseCase(this._repository);

  Future<void> call(
    String foodName,
    double calories, {
    double? protein,
    double? carbs,
    double? fat,
    String? reason,
    String? nutritionDetails,
    RecordType recordType = RecordType.manual,
  }) async {
    final foodRecord = FoodRecordEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: foodName,
      calories: calories,
      date: DateTime.now(),
      protein: protein,
      carbs: carbs,
      fat: fat,
      reason: reason,
      nutritionDetails: nutritionDetails,
      recordType: recordType,
    );

    await _repository.saveFoodRecord(foodRecord);
  }
}
