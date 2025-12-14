import '../../domain/entities/chat_session_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
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
    // Try local first
    final local = await _localDataSource.getSessionById(id);
    if (local != null) return local;

    // Fallback: load from cloud (Firestore) and hydrate into local cache
    try {
      final remoteMeta = await _cloudService.getSessionById(id);
      if (remoteMeta == null) return null;

      // Fetch messages ordered by timestamp
      final remoteMsgs = await _cloudService.getMessages(id);
      remoteMsgs.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      final messages = remoteMsgs
          .map(
            (m) => ChatMessageEntity(
              text: m.content,
              isUser: m.role == ChatRole.user,
              timestamp: m.timestamp,
            ),
          )
          .toList();

      final session = ChatSessionEntity(
        id: remoteMeta.id,
        title: remoteMeta.title,
        createdAt: remoteMeta.createdAt,
        lastMessageAt: remoteMeta.lastMessageAt,
        messages: messages,
      );

      // Cache locally for fast subsequent loads
      await _localDataSource.saveSession(session);
      return session;
    } catch (_) {
      return null;
    }
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
        // If cloud has no messages yet and the first local message is a bot
        // welcome message, skip it so that the first stored message is the
        // user's message (so auto-title uses user content as desired).
        int startIndex = remoteCount;
        if (remoteCount == 0 && msgs.isNotEmpty && !msgs.first.isUser) {
          startIndex = 1;
        }
        for (int i = startIndex; i < msgs.length; i++) {
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
    // Create only in local cache; do NOT touch cloud until a user message is saved
    final id = await _localDataSource.createNewSession(title: title);
    return id;
  }

  @override
  Future<String?> getMostRecentSessionIdFromCloud() async {
    try {
      final meta = await _cloudService.getMostRecentSession();
      return meta?.id;
    } catch (_) {
      return null;
    }
  }
}
