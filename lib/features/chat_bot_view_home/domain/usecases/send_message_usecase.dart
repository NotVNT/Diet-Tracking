import '../repositories/chat_repository.dart';
import '../repositories/user_repository.dart';

/// Use case for sending a message and getting AI response
class SendMessageUseCase {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;

  SendMessageUseCase(this._chatRepository, this._userRepository);

  /// Execute the use case
  Future<SendMessageResult> execute(
    String message, {
    Map<String, dynamic>? extraContext,
  }) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _userRepository.isUserAuthenticated();
      if (!isAuthenticated) {
        return SendMessageResult.failure("Bạn chưa đăng nhập!");
      }

      // Get user data
      final userDataEntity = await _userRepository.getCurrentUserData();
      if (userDataEntity == null) {
        return SendMessageResult.failure("Không thể lấy thông tin người dùng!");
      }

      // Convert UserDataEntity to a Map
      final Map<String, dynamic> userData = {
        'age': userDataEntity.age,
        'height': userDataEntity.height,
        'weight': userDataEntity.weight,
        'goalWeightKg': userDataEntity.goalWeightKg,
        'disease': userDataEntity.disease,
        'allergy': userDataEntity.allergy,
        'goal': userDataEntity.goal,
        'gender': userDataEntity.gender,
      };

      // Get nutrition plan data
      final nutritionPlan = await _userRepository.getNutritionPlan();
      if (nutritionPlan != null) {
        // Merge nutrition plan into user data
        userData['nutrition_plan'] = nutritionPlan.toJson();
      }

      // Get recent food records
      final foodRecords = await _userRepository.getRecentFoodRecords();
      if (foodRecords.isNotEmpty) {
        userData['food_records'] = foodRecords;
      }

      // Merge any extra context (e.g., food_scan JSON)
      if (extraContext != null && extraContext.isNotEmpty) {
        userData.addAll(extraContext);
      }

      // Send message and get response
      final response = await _chatRepository.sendMessage(message, userData);
      return SendMessageResult.success(response);
    } catch (e) {
      // Hide technical details from end-users
      return SendMessageResult.failure(
        "Không thể gửi tin nhắn. Vui lòng kiểm tra kết nối và thử lại.",
      );
    }
  }
}

/// Result class for send message operation
class SendMessageResult {
  final bool isSuccess;
  final String? response;
  final String? error;

  SendMessageResult._({required this.isSuccess, this.response, this.error});

  factory SendMessageResult.success(String response) {
    return SendMessageResult._(isSuccess: true, response: response);
  }

  factory SendMessageResult.failure(String error) {
    return SendMessageResult._(isSuccess: false, error: error);
  }
}
