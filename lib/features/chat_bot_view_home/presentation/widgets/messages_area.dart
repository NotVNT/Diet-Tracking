import 'package:flutter/material.dart';
import '../../domain/entities/chat_message_entity.dart';
import 'chat_message_bubble.dart';

/// Widget to display chat messages with auto-scroll functionality
/// Automatically scrolls to the latest message when returning to the page
class MessagesArea extends StatefulWidget {
  final List<ChatMessageEntity> messages;
  final bool isLoading;

  const MessagesArea({
    super.key,
    required this.messages,
    this.isLoading = false,
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
    // Scroll to bottom when messages or loading state change
    if (widget.messages.length != oldWidget.messages.length ||
        widget.isLoading != oldWidget.isLoading) {
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
    final itemCount = widget.messages.length + (widget.isLoading ? 1 : 0);
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (index < widget.messages.length) {
            final message = widget.messages[index];
            return ChatMessageBubble(message: message);
          }
          // Typing/loading indicator bubble (bot side)
          return _buildTypingIndicator(context);
        },
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: const Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang phân tích…',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
