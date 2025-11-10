import '../../../../model/nutrition_calculation_model.dart';
import '../entities/user_data_entity.dart';

/// Repository interface for user data operations
abstract class UserRepository {
  /// Get current user data from Firestore
  Future<UserDataEntity?> getCurrentUserData();

  /// Check if user is authenticated
  Future<bool> isUserAuthenticated();

  /// Get user ID
  Future<String?> getCurrentUserId();

  /// Get active nutrition plan for the current user
  Future<NutritionCalculation?> getNutritionPlan();

  /// Get recent food records for the current user
  Future<List<Map<String, dynamic>>> getRecentFoodRecords();
}
