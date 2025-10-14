import '../entities/chat_session_entity.dart';

/// Repository interface for chat session management
abstract class ChatSessionRepository {
  /// Get all chat sessions
  Future<List<ChatSessionEntity>> getAllSessions();

  /// Get a specific chat session by ID
  Future<ChatSessionEntity?> getSessionById(String id);

  /// Save a chat session
  Future<void> saveSession(ChatSessionEntity session);

  /// Delete a chat session
  Future<void> deleteSession(String id);

  /// Get the current active session ID
  Future<String?> getCurrentSessionId();

  /// Set the current active session ID
  Future<void> setCurrentSessionId(String id);

  /// Create a new session and return its ID
  Future<String> createNewSession({String? title});
}
