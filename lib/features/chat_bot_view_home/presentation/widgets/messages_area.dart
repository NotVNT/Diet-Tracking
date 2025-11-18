import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'chat_message_bubble.dart';

/// Widget to display chat messages with auto-scroll functionality
/// Automatically scrolls to the latest message when returning to the page
class MessagesArea extends StatefulWidget {
  final List<ChatMessageEntity> messages;

  const MessagesArea({
    super.key,
    required this.messages,
  });

  @override
  State<MessagesArea> createState() => _MessagesAreaState();
}

class _MessagesAreaState extends State<MessagesArea> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Scroll to bottom after first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(MessagesArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scroll to bottom when messages change
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Scrolls to the bottom of the message list
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(
        _scrollController.position.maxScrollExtent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          final message = widget.messages[index];
          return ChatMessageBubble(message: message);
        },
      ),
    );
  }
}
