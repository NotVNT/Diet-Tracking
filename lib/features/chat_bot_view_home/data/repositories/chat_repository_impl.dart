import '../../domain/entities/chat_message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chatbot_endpoint_datasource.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final GeminiApiDatasource _geminiApiDatasource;

  ChatRepositoryImpl(this._geminiApiDatasource);

  @override
  Future<String> sendMessage(
    String message,
    Map<String, dynamic> contextData,
  ) async {
    // Pass the context data map directly to the datasource
    return await _geminiApiDatasource.sendMessage(message, contextData);
  }

  @override
  Future<List<ChatMessageEntity>> getChatHistory() async {
    
    return [];
  }

  @override
  Future<void> saveChatMessage(ChatMessageEntity message) async {
   
  }

  @override
  Future<void> clearChatHistory() async {
  
  }
}
