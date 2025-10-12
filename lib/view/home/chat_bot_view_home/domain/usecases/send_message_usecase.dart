import '../repositories/chat_repository.dart';
import '../repositories/user_repository.dart';

/// Use case for sending a message and getting AI response
class SendMessageUseCase {
  final ChatRepository _chatRepository;
  final UserRepository _userRepository;

  SendMessageUseCase(this._chatRepository, this._userRepository);

  /// Execute the use case
  Future<SendMessageResult> execute(String message) async {
    try {
      // Check if user is authenticated
      final isAuthenticated = await _userRepository.isUserAuthenticated();
      if (!isAuthenticated) {
        return SendMessageResult.failure("Bạn chưa đăng nhập!");
      }

      // Get user data
      final userData = await _userRepository.getCurrentUserData();
      if (userData == null) {
        return SendMessageResult.failure("Không thể lấy thông tin người dùng!");
      }

      // Send message and get response
      final response = await _chatRepository.sendMessage(message, userData);
      return SendMessageResult.success(response);
    } catch (e) {
      return SendMessageResult.failure("Lỗi khi gửi tin nhắn: ${e.toString()}");
    }
  }
}

/// Result class for send message operation
class SendMessageResult {
  final bool isSuccess;
  final String? response;
  final String? error;

  SendMessageResult._({
    required this.isSuccess,
    this.response,
    this.error,
  });

  factory SendMessageResult.success(String response) {
    return SendMessageResult._(
      isSuccess: true,
      response: response,
    );
  }

  factory SendMessageResult.failure(String error) {
    return SendMessageResult._(
      isSuccess: false,
      error: error,
    );
  }
}
