import '../entities/scanned_food_entity.dart';

/// Repository interface for managing scanned food items
abstract class ScannedFoodRepository {
  /// Save a new scanned food item
  Future<void> saveScannedFood(ScannedFoodEntity food);

  /// Get all scanned food items, sorted by date (newest first)
  Future<List<ScannedFoodEntity>> getAllScannedFoods();

  /// Get recent scanned food items (limit to specified count)
  Future<List<ScannedFoodEntity>> getRecentScannedFoods({int limit = 10});

  /// Delete a scanned food item
  Future<void> deleteScannedFood(String id);

  /// Clear all scanned food items
  Future<void> clearAllScannedFoods();

  /// Mark a scanned food as processed
  Future<void> markAsProcessed(String id);
}
