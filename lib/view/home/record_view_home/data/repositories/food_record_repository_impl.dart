import '../../domain/entities/food_record_entity.dart';
import '../../domain/repositories/food_record_repository.dart';
import '../models/food_record_model.dart';
import '../../../../../database/local_storage_service.dart';

class FoodRecordRepositoryImpl implements FoodRecordRepository {
  final LocalStorageService _localStorageService;

  FoodRecordRepositoryImpl(this._localStorageService);

  @override
  Future<void> saveFoodRecord(FoodRecordEntity foodRecord) async {
    final model = FoodRecordModel.fromEntity(foodRecord);
    final records = await getFoodRecords();
    final updatedRecords = [...records, model];
    
    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();
    
    await _localStorageService.saveData('food_records', jsonList);
  }

  @override
  Future<List<FoodRecordEntity>> getFoodRecords() async {
    final data = await _localStorageService.getData('food_records');
    if (data == null) return [];
    
    final List<dynamic> jsonList = data;
    return jsonList
        .map((json) => FoodRecordModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> deleteFoodRecord(String id) async {
    final records = await getFoodRecords();
    final updatedRecords = records.where((record) => record.id != id).toList();
    
    final jsonList = updatedRecords
        .map((record) => FoodRecordModel.fromEntity(record).toJson())
        .toList();
    
    await _localStorageService.saveData('food_records', jsonList);
  }
}
