import 'chat_message_entity.dart';

/// Entity representing a chat session
class ChatSessionEntity {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessageEntity> messages;

  const ChatSessionEntity({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  });

  /// Create a new chat session with default welcome message
  factory ChatSessionEntity.createNew({
    required String id,
    String? title,
  }) {
    final now = DateTime.now();
    final welcomeMessage = ChatMessageEntity(
      text: 'Xin chào! Tôi có thể giúp gì cho bạn hôm nay?',
      isUser: false,
      timestamp: now,
    );

    return ChatSessionEntity(
      id: id,
      title: title ?? 'Cuộc trò chuyện mới',
      createdAt: now,
      lastMessageAt: now,
      messages: [welcomeMessage],
    );
  }

  /// Copy with new values
  ChatSessionEntity copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessageEntity>? messages,
  }) {
    return ChatSessionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }

  /// Add a message to this session
  ChatSessionEntity addMessage(ChatMessageEntity message) {
    final updatedMessages = List<ChatMessageEntity>.from(messages)..add(message);
    return copyWith(
      messages: updatedMessages,
      lastMessageAt: message.timestamp,
    );
  }

  /// Generate title from first user message
  String generateTitleFromFirstMessage() {
    final firstUserMessage = messages.firstWhere(
      (msg) => msg.isUser,
      orElse: () => ChatMessageEntity(
        text: 'Cuộc trò chuyện mới',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    );

    String title = firstUserMessage.text;
    if (title.length > 30) {
      title = '${title.substring(0, 30)}...';
    }
    return title;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSessionEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ChatSessionEntity(id: $id, title: $title, messagesCount: ${messages.length})';
  }
}
