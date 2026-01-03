import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget for chat input area with text field and send button
class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendPressed;
  final Function(String) onMessageSubmitted;

  const ChatInputArea({
    super.key,
    required this.messageController,
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
          _buildMessageInputField(context),
          const SizedBox(width: 8),
          _buildSendButton(context),
        ],
      ),
    );
  }

  /// Builds the message input text field
  Widget _buildMessageInputField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: messageController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
          decoration: InputDecoration(
            hintText: l10n.chatBotEnterMessage,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
