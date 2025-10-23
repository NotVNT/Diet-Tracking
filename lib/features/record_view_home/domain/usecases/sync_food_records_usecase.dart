import '../repositories/food_record_repository.dart';

class SyncFoodRecordsUseCase {
  final FoodRecordRepository _repository;

  SyncFoodRecordsUseCase(this._repository);

  Future<void> call() async {
    return await _repository.syncWithFirestore();
  }
}
