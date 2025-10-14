import '../entities/chat_message_entity.dart';
import '../entities/user_data_entity.dart';

/// Repository interface for chat operations
abstract class ChatRepository {
  /// Send a message and get AI response
  Future<String> sendMessage(String message, UserDataEntity userData);
  
  /// Get chat history (if needed for future implementation)
  Future<List<ChatMessageEntity>> getChatHistory();
  
  /// Save chat message (if needed for future implementation)
  Future<void> saveChatMessage(ChatMessageEntity message);
  
  /// Clear chat history (if needed for future implementation)
  Future<void> clearChatHistory();
}
