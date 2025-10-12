import '../entities/food_record_entity.dart';

abstract class FoodRecordRepository {
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord);
  Future<List<FoodRecordEntity>> getFoodRecords();
  Future<void> deleteFoodRecord(String id);
}
