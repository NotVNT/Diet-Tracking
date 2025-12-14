import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum ChatRole { user, bot }

String _roleToString(ChatRole r) => r == ChatRole.user ? 'user' : 'bot';

class ChatMessageFS {
  final String id;
  final ChatRole role;
  final String content;
  final DateTime timestamp;

  ChatMessageFS({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'role': _roleToString(role),
    'content': content,
    'ts': FieldValue.serverTimestamp(),
  };

  factory ChatMessageFS.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    final ts = (m['ts'] is Timestamp)
        ? (m['ts'] as Timestamp).toDate()
        : DateTime.now();
    final roleStr = (m['role'] as String?) ?? 'user';
    return ChatMessageFS(
      id: doc.id,
      role: roleStr == 'bot' ? ChatRole.bot : ChatRole.user,
      content: (m['content'] as String?) ?? '',
      timestamp: ts,
    );
  }
}

class ChatSessionFS {
  final String id;
  final String title;
  final String lastMessagePreview;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final int messageCount;

  ChatSessionFS({
    required this.id,
    required this.title,
    required this.lastMessagePreview,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messageCount,
  });

  factory ChatSessionFS.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>? ?? {};
    final created = (m['createdAt'] is Timestamp)
        ? (m['createdAt'] as Timestamp).toDate()
        : DateTime.now();
    final last = (m['lastMessageAt'] is Timestamp)
        ? (m['lastMessageAt'] as Timestamp).toDate()
        : created;
    return ChatSessionFS(
      id: doc.id,
      title: (m['title'] as String?) ?? 'Cuộc trò chuyện mới',
      lastMessagePreview: (m['lastMessagePreview'] as String?) ?? '',
      createdAt: created,
      lastMessageAt: last,
      messageCount: (m['messageCount'] as int?) ?? 0,
    );
  }
}

class ChatSessionsService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  ChatSessionsService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String _uidOrThrow() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');
    return user.uid;
  }

  CollectionReference _sessionsCol(String uid) =>
      _db.collection('users').doc(uid).collection('chat_sessions');

  CollectionReference _messagesCol(String uid, String sessionId) =>
      _sessionsCol(uid).doc(sessionId).collection('messages');

  Stream<List<ChatSessionFS>> streamSessionsForCurrentUser() {
    final uid = _uidOrThrow();
    return _sessionsCol(uid)
        .orderBy('lastMessageAt', descending: true)
        .limit(5)
        .snapshots()
        .map((qs) => qs.docs.map(ChatSessionFS.fromDoc).toList());
  }

  Future<ChatSessionFS?> getMostRecentSession() async {
    try {
      final uid = _uidOrThrow();
      final querySnapshot = await _sessionsCol(
        uid,
      ).orderBy('lastMessageAt', descending: true).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        return ChatSessionFS.fromDoc(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      // Handle cases where user is not logged in or other Firestore errors
      // ignore: avoid_print
      print('Error getting most recent session: $e');
      return null;
    }
  }

  Future<String> createSession({
    String? title,
    bool autoDeleteOldest = true,
  }) async {
    final uid = _uidOrThrow();
    return _db.runTransaction((tx) async {
      final sessionsQuery = await _sessionsCol(
        uid,
      ).orderBy('createdAt').limit(6).get();
      if (sessionsQuery.docs.length >= 5) {
        if (autoDeleteOldest) {
          final oldest = sessionsQuery.docs.first;
          tx.delete(oldest.reference);
        } else {
          throw Exception('Bạn chỉ có thể lưu tối đa 5 cuộc trò chuyện');
        }
      }
      final ref = _sessionsCol(uid).doc();
      tx.set(ref, {
        'title': title ?? 'Cuộc trò chuyện mới',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': '',
        'messageCount': 0,
      });
      return ref.id;
    });
  }

  Future<void> ensureSessionWithClientId(
    String sessionId, {
    String? title,
    bool autoDeleteOldest = true,
  }) async {
    final uid = _uidOrThrow();
    await _db.runTransaction((tx) async {
      final sessionRef = _sessionsCol(uid).doc(sessionId);
      final existing = await tx.get(sessionRef);
      if (existing.exists) {
        // Optionally update missing fields
        return;
      }

      // Enforce limit
      final sessionsQuery = await _sessionsCol(
        uid,
      ).orderBy('createdAt').limit(6).get();
      if (sessionsQuery.docs.length >= 5) {
        if (autoDeleteOldest) {
          final oldest = sessionsQuery.docs.first;
          tx.delete(oldest.reference);
        } else {
          throw Exception('Bạn chỉ có thể lưu tối đa 5 cuộc trò chuyện');
        }
      }

      tx.set(sessionRef, {
        'title': title ?? 'Cuộc trò chuyện mới',
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': '',
        'messageCount': 0,
      });
    });
  }

  /// Fetch a session meta by ID for current user; returns null if not found
  Future<ChatSessionFS?> getSessionById(String sessionId) async {
    final uid = _uidOrThrow();
    final snap = await _sessionsCol(uid).doc(sessionId).get();
    if (!snap.exists) return null;
    return ChatSessionFS.fromDoc(snap);
  }

  Future<void> deleteSession(String sessionId) async {
    final uid = _uidOrThrow();
    // Delete sub-collection messages in a batch (paginated if large)
    final msgs = await _messagesCol(uid, sessionId).limit(500).get();
    final batch = _db.batch();
    for (final d in msgs.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_sessionsCol(uid).doc(sessionId));
    await batch.commit();
  }

  String buildPreview(String text) {
    final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    return t.length <= 50 ? t : '${t.substring(0, 50)}…';
  }

  String buildTitle(String text) {
    final t = text.trim();
    return t.length <= 30 ? t : '${t.substring(0, 30)}…';
  }

  Future<void> addMessage({
    required String sessionId,
    required ChatRole role,
    required String content,
  }) async {
    final uid = _uidOrThrow();
    final sessionRef = _sessionsCol(uid).doc(sessionId);
    final messagesRef = _messagesCol(uid, sessionId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(sessionRef);
      if (!snap.exists) throw Exception('Phiên chat không tồn tại');

      final preview = buildPreview(content);
      final data = ChatMessageFS(
        id: '',
        role: role,
        content: content,
        timestamp: DateTime.now(),
      ).toMap();
      final newMsgRef = messagesRef.doc();
      tx.set(newMsgRef, data);

      // update session meta
      final m = snap.data() as Map<String, dynamic>? ?? {};
      final currentCount = (m['messageCount'] as int?) ?? 0;
      final shouldAutoTitle = currentCount == 0 && role == ChatRole.user;
      tx.update(sessionRef, {
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastMessagePreview': preview,
        'messageCount': currentCount + 1,
        if (shouldAutoTitle) 'title': buildTitle(content),
      });
    });
  }

  /// Fetch messages for a session (ordered by timestamp asc)
  Future<List<ChatMessageFS>> getMessages(
    String sessionId, {
    int limit = 500,
  }) async {
    final uid = _uidOrThrow();
    final qs = await _messagesCol(
      uid,
      sessionId,
    ).orderBy('ts').limit(limit).get();
    return qs.docs.map(ChatMessageFS.fromDoc).toList();
  }
}
