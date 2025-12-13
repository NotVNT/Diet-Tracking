import '../../domain/entities/chat_session_entity.dart';
import '../../domain/repositories/chat_session_repository.dart';
import '../datasources/chat_session_local_data_source.dart';
import '../../../../services/chat_sessions_service.dart';

/// Implementation of ChatSessionRepository
/// - Persists locally via ChatSessionLocalDataSource
/// - Then synchronizes to Firestore in background via ChatSessionsService
class ChatSessionRepositoryImpl implements ChatSessionRepository {
  final ChatSessionLocalDataSource _localDataSource;
  final ChatSessionsService _cloudService;

  ChatSessionRepositoryImpl(this._localDataSource, this._cloudService);

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
    // Save locally first
    await _localDataSource.saveSession(session);

    // Fire-and-forget sync to cloud (still awaited here since caller isn't blocking UI)
    try {
      // Ensure remote session with same ID exists
      await _cloudService.ensureSessionWithClientId(
        session.id,
        title: session.title,
      );

      // Determine how many messages remote already has
      final remoteMeta = await _cloudService.getSessionById(session.id);
      final remoteCount = remoteMeta?.messageCount ?? 0;

      final msgs = session.messages;
      if (remoteCount < msgs.length) {
        for (int i = remoteCount; i < msgs.length; i++) {
          final m = msgs[i];
          await _cloudService.addMessage(
            sessionId: session.id,
            role: m.isUser ? ChatRole.user : ChatRole.bot,
            content: m.text,
          );
        }
      }
    } catch (e) {
      // Swallow errors to avoid breaking local UX; can add logging if needed
    }
  }

  @override
  Future<void> deleteSession(String id) async {
    await _localDataSource.deleteSession(id);
    // Optional: also delete on cloud; skipping per requirement scope
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
    final id = await _localDataSource.createNewSession(title: title);
    // Ensure cloud record exists as well (best-effort)
    try {
      await _cloudService.ensureSessionWithClientId(id, title: title);
    } catch (_) {}
    return id;
  }
}
