/// Domain entity for chat messages
class ChatMessageEntity {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessageEntity &&
        other.text == text &&
        other.isUser == isUser &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => text.hashCode ^ isUser.hashCode ^ timestamp.hashCode;

  @override
  String toString() {
    return 'ChatMessageEntity(text: $text, isUser: $isUser, timestamp: $timestamp)';
  }
}
