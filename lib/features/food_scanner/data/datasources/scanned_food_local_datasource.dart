import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_scanner_models.dart';

/// Local datasource for scanned food items using SharedPreferences
class ScannedFoodLocalDataSource {
  static const String _keyScannedFoods = 'scanned_foods';

  /// Get SharedPreferences instance
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Save a scanned food item
  Future<void> saveScannedFood(ScannedFoodModel food) async {
    final prefs = await _prefs;
    final foods = await _getAllScannedFoods();
    foods.removeWhere(
      (existing) =>
          existing.id == food.id || existing.imagePath == food.imagePath,
    );

    // Add new food to the beginning of the list
    foods.insert(0, food);

    // Convert to JSON and save
    final jsonList = foods.map((f) => f.toJson()).toList();
    await prefs.setString(_keyScannedFoods, jsonEncode(jsonList));
  }

  /// Get all scanned food items
  Future<List<ScannedFoodModel>> getAllScannedFoods() async {
    return await _getAllScannedFoods();
  }

  /// Internal method to get all scanned foods
  Future<List<ScannedFoodModel>> _getAllScannedFoods() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_keyScannedFoods);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map(
            (json) => ScannedFoodModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      // If parsing fails, return empty list and clear corrupted data
      await prefs.remove(_keyScannedFoods);
      return [];
    }
  }

  /// Delete a scanned food item by id
  Future<void> deleteScannedFood(String id) async {
    final prefs = await _prefs;
    final foods = await _getAllScannedFoods();

    // Remove the item with matching id or url
    foods.removeWhere((food) => food.id == id || food.imagePath == id);

    // Save updated list
    final jsonList = foods.map((f) => f.toJson()).toList();
    await prefs.setString(_keyScannedFoods, jsonEncode(jsonList));
  }

  /// Clear all scanned food items
  Future<void> clearAllScannedFoods() async {
    final prefs = await _prefs;
    await prefs.remove(_keyScannedFoods);
  }

  /// Mark a scanned food as processed
  Future<void> markAsProcessed(String id) async {
    final prefs = await _prefs;
    final foods = await _getAllScannedFoods();

    // Find and update the item (match by id or url)
    final index = foods.indexWhere(
      (food) => food.id == id || food.imagePath == id,
    );
    if (index != -1) {
      foods[index] = ScannedFoodModel(
        id: foods[index].id,
        imagePath: foods[index].imagePath,
        scanType: foods[index].scanType,
        scanDate: foods[index].scanDate,
        isProcessed: true,
      );

      // Save updated list
      final jsonList = foods.map((f) => f.toJson()).toList();
      await prefs.setString(_keyScannedFoods, jsonEncode(jsonList));
    }
  }
}
