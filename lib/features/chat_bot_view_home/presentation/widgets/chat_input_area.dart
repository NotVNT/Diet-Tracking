import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for chat input area with text field and send button
class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final bool showOptions;
  final VoidCallback onToggleOptions;
  final VoidCallback onSendPressed;
  final Function(String) onMessageSubmitted;

  const ChatInputArea({
    super.key,
    required this.messageController,
    required this.showOptions,
    required this.onToggleOptions,
    required this.onSendPressed,
    required this.onMessageSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildOptionsToggleButton(context),
          const SizedBox(width: 8),
          _buildMessageInputField(context),
          const SizedBox(width: 8),
          _buildSendButton(context),
        ],
      ),
    );
  }

  /// Builds the options toggle button
  Widget _buildOptionsToggleButton(BuildContext context) {
    return IconButton(
      onPressed: onToggleOptions,
      icon: Icon(
        showOptions ? Icons.close : Icons.add,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  /// Builds the message input text field
  Widget _buildMessageInputField(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: messageController,
          style: GoogleFonts.inter(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Nhập tin nhắn...',
            hintStyle: GoogleFonts.inter(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onSubmitted: onMessageSubmitted,
        ),
      ),
    );
  }

  /// Builds the send message button
  Widget _buildSendButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onSendPressed,
        icon: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }
}
