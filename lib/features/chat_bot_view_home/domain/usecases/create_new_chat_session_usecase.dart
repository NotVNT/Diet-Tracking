import '../entities/chat_session_entity.dart';
import '../repositories/chat_session_repository.dart';

/// Use case for creating a new chat session
class CreateNewChatSessionUseCase {
  final ChatSessionRepository _repository;

  CreateNewChatSessionUseCase(this._repository);

  /// Execute the use case to create a new chat session
  Future<ChatSessionEntity> execute({String? title}) async {
    // Create new session ID
    final sessionId = await _repository.createNewSession(title: title);
    
    // Create new session entity
    final newSession = ChatSessionEntity.createNew(
      id: sessionId,
      title: title,
    );
    
    // Save the session
    await _repository.saveSession(newSession);
    
    // Set as current active session
    await _repository.setCurrentSessionId(sessionId);
    
    return newSession;
  }
}
