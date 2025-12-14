import '../entities/chat_session_entity.dart';
import '../repositories/chat_session_repository.dart';

/// Use case for creating a new chat session
class CreateNewChatSessionUseCase {
  final ChatSessionRepository _repository;

  CreateNewChatSessionUseCase(this._repository);

  /// Execute the use case to create a new chat session
  /// Note: This creates a LOCAL-ONLY session (in-memory) and does NOT
  /// write to Firestore until the first user message is sent.
  Future<ChatSessionEntity> execute({String? title}) async {
    // Create new session ID (local in-memory store)
    final sessionId = await _repository.createNewSession(title: title);

    // Create new session entity (with welcome message)
    final newSession = ChatSessionEntity.createNew(id: sessionId, title: title);

    // Do NOT save to repository/cloud yet – defer until first user message

    // Set as current active session
    await _repository.setCurrentSessionId(sessionId);

    return newSession;
  }
}
