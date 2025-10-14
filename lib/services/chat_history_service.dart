import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String role; // "user" | "model"
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toUtc().toIso8601String(),
      };

  factory ChatMessage.fromMap(Map<String, dynamic> m) {
    return ChatMessage(
      role: (m['role'] as String?) ?? 'user',
      content: (m['content'] as String?) ?? '',
      timestamp: DateTime.tryParse((m['timestamp'] as String?) ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
    );
  }
}

final FirebaseFirestore _db = FirebaseFirestore.instance;

// Theo yêu cầu: tên hàm chính xác
Future<void> save_history_to_firestore(
  String userId,
  List<ChatMessage> history,
) async {
  final doc = _db
      .collection('users')
      .doc(userId)
      .collection('chat')
      .doc('chatHistory');
  await doc.set(
    {
      'messages': history.map((m) => m.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
}

// Theo yêu cầu: tên hàm chính xác
Future<List<ChatMessage>> load_history_from_firestore(String userId) async {
  final doc = await _db
      .collection('users')
      .doc(userId)
      .collection('chat')
      .doc('chatHistory')
      .get();
  if (!doc.exists) return [];
  final data = doc.data() ?? {};
  final arr = (data['messages'] as List<dynamic>?) ?? [];
  return arr
      .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
      .toList();
}

