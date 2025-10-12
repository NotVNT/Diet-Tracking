import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/user_data_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/gemini_api_datasource.dart';

import '../models/user_data_model.dart';

/// Implementation of ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final GeminiApiDatasource _geminiApiDatasource;

  ChatRepositoryImpl(this._geminiApiDatasource);

  @override
  Future<String> sendMessage(String message, UserDataEntity userData) async {
    final userDataModel = UserDataModel.fromEntity(userData);
    return await _geminiApiDatasource.sendMessage(message, userDataModel);
  }

  @override
  Future<List<ChatMessageEntity>> getChatHistory() async {
    // TODO: Implement chat history storage if needed
    return [];
  }

  @override
  Future<void> saveChatMessage(ChatMessageEntity message) async {
    // TODO: Implement chat message saving if needed
  }

  @override
  Future<void> clearChatHistory() async {
    // TODO: Implement chat history clearing if needed
  }
}
