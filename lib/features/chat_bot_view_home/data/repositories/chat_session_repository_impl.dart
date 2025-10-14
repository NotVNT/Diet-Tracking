import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_session_repository.dart';
import '../datasources/chat_session_local_data_source.dart';

/// Implementation of ChatSessionRepository
class ChatSessionRepositoryImpl implements ChatSessionRepository {
  final ChatSessionLocalDataSource _localDataSource;

  ChatSessionRepositoryImpl(this._localDataSource);

  @override
  Future<List<ChatSessionEntity>> getAllSessions() async {
    return await _localDataSource.getAllSessions();
  }

  @override
  Future<ChatSessionEntity?> getSessionById(String id) async {
    return await _localDataSource.getSessionById(id);
  }

  @override
  Future<void> saveSession(ChatSessionEntity session) async {
    await _localDataSource.saveSession(session);
  }

  @override
  Future<void> deleteSession(String id) async {
    await _localDataSource.deleteSession(id);
  }

  @override
  Future<String?> getCurrentSessionId() async {
    return await _localDataSource.getCurrentSessionId();
  }

  @override
  Future<void> setCurrentSessionId(String id) async {
    await _localDataSource.setCurrentSessionId(id);
  }

  @override
  Future<String> createNewSession({String? title}) async {
    return await _localDataSource.createNewSession(title: title);
  }
}
