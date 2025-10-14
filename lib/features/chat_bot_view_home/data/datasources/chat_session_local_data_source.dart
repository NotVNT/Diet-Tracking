import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_session_entity.dart';

/// Abstract class for local data source for chat sessions
abstract class ChatSessionLocalDataSource {
  Future<List<ChatSessionEntity>> getAllSessions();
  Future<ChatSessionEntity?> getSessionById(String id);
  Future<void> saveSession(ChatSessionEntity session);
  Future<void> deleteSession(String id);
  Future<String?> getCurrentSessionId();
  Future<void> setCurrentSessionId(String id);
  Future<String> createNewSession({String? title});
}

/// In-memory implementation of the local data source
class InMemoryChatSessionLocalDataSource implements ChatSessionLocalDataSource {
  final Map<String, ChatSessionEntity> _sessions = {};
  String? _currentSessionId;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<ChatSessionEntity>> getAllSessions() async {
    return _sessions.values.toList();
  }

  @override
  Future<ChatSessionEntity?> getSessionById(String id) async {
    return _sessions[id];
  }

  @override
  Future<void> saveSession(ChatSessionEntity session) async {
    _sessions[session.id] = session;
  }

  @override
  Future<void> deleteSession(String id) async {
    _sessions.remove(id);
  }

  @override
  Future<String?> getCurrentSessionId() async {
    return _currentSessionId;
  }

  @override
  Future<void> setCurrentSessionId(String id) async {
    _currentSessionId = id;
  }

  @override
  Future<String> createNewSession({String? title}) async {
    final sessionId = _uuid.v4();
    final newSession = ChatSessionEntity.createNew(
      id: sessionId,
      title: title,
    );
    _sessions[sessionId] = newSession;
    _currentSessionId = sessionId;
    return sessionId;
  }
}
