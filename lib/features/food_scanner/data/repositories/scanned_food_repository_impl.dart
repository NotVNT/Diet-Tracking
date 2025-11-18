import '../../domain/entities/scanned_food_entity.dart';
import '../../domain/repositories/scanned_food_repository.dart';
import '../datasources/scanned_food_local_datasource.dart';
import '../models/scanned_food_model.dart';

/// Implementation of ScannedFoodRepository
class ScannedFoodRepositoryImpl implements ScannedFoodRepository {
  final ScannedFoodLocalDataSource localDataSource;

  ScannedFoodRepositoryImpl({required this.localDataSource});

  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {
    final model = ScannedFoodModel.fromEntity(food);
    await localDataSource.saveScannedFood(model);
  }

  @override
  Future<List<ScannedFoodEntity>> getAllScannedFoods() async {
    final models = await localDataSource.getAllScannedFoods();
    return models.cast<ScannedFoodEntity>();
  }

  @override
  Future<List<ScannedFoodEntity>> getRecentScannedFoods({int limit = 10}) async {
    final models = await localDataSource.getAllScannedFoods();
    final limitedModels = models.take(limit).toList();
    return limitedModels.cast<ScannedFoodEntity>();
  }

  @override
  Future<void> deleteScannedFood(String id) async {
    await localDataSource.deleteScannedFood(id);
  }

  @override
  Future<void> clearAllScannedFoods() async {
    await localDataSource.clearAllScannedFoods();
  }

  @override
  Future<void> markAsProcessed(String id) async {
    await localDataSource.markAsProcessed(id);
  }
}
