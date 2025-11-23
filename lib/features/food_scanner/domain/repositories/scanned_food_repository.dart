import '../entities/scanned_food_entity.dart';

/// Repository interface for managing scanned food items
abstract class ScannedFoodRepository {
  /// Save a new scanned food item
  Future<void> saveScannedFood(ScannedFoodEntity food);
}
