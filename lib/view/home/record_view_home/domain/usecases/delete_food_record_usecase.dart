import '../repositories/food_record_repository.dart';

class DeleteFoodRecordUseCase {
  final FoodRecordRepository _repository;

  DeleteFoodRecordUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteFoodRecord(id);
  }
}
