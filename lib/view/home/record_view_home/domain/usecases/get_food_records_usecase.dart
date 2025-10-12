import '../entities/food_record_entity.dart';
import '../repositories/food_record_repository.dart';

class GetFoodRecordsUseCase {
  final FoodRecordRepository _repository;

  GetFoodRecordsUseCase(this._repository);

  Future<List<FoodRecordEntity>> call() async {
    return await _repository.getFoodRecords();
  }
}
