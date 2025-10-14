import '../../domain/entities/chat_message_entity.dart';

/// Data model for chat messages with JSON serialization
class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.text,
    required super.isUser,
    required super.timestamp,
  });

  /// Creates a ChatMessageModel from a ChatMessageEntity
  factory ChatMessageModel.fromEntity(ChatMessageEntity entity) {
    return ChatMessageModel(
      text: entity.text,
      isUser: entity.isUser,
      timestamp: entity.timestamp,
    );
  }

  /// Creates a ChatMessageModel from JSON
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Converts the model to entity
  ChatMessageEntity toEntity() {
    return ChatMessageEntity(
      text: text,
      isUser: isUser,
      timestamp: timestamp,
    );
  }

  @override
  String toString() {
    return 'ChatMessageModel(text: $text, isUser: $isUser, timestamp: $timestamp)';
  }
}
