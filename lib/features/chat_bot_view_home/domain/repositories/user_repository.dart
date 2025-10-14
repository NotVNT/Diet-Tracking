import '../entities/user_data_entity.dart';

/// Repository interface for user data operations
abstract class UserRepository {
  /// Get current user data from Firestore
  Future<UserDataEntity?> getCurrentUserData();
  
  /// Check if user is authenticated
  Future<bool> isUserAuthenticated();
  
  /// Get user ID
  Future<String?> getCurrentUserId();
}
