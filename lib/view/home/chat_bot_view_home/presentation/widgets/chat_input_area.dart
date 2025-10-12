import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget for chat input area with text field and send button
class ChatInputArea extends StatelessWidget {
  final TextEditingController messageController;
  final bool showOptions;
  final VoidCallback onToggleOptions;
  final VoidCallback onSendPressed;
  final Function(String) onMessageSubmitted;

  static const Color _backgroundColor = Color(0xFF1A1A1A);
  static const Color _messageBubbleColor = Color(0xFF2D2D2D);
  static const Color _inputBackgroundColor = Color(0xFF2D2D2D);
  static const Color _primaryColor = Color(0xFF4CAF50);

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
      decoration: const BoxDecoration(
        color: _backgroundColor,
        border: Border(top: BorderSide(color: _messageBubbleColor, width: 1)),
      ),
      child: Row(
        children: [
          _buildOptionsToggleButton(),
          const SizedBox(width: 8),
          _buildMessageInputField(),
          const SizedBox(width: 8),
          _buildSendButton(),
        ],
      ),
    );
  }

  /// Builds the options toggle button
  Widget _buildOptionsToggleButton() {
    return IconButton(
      onPressed: onToggleOptions,
      icon: Icon(showOptions ? Icons.close : Icons.add, color: Colors.white),
    );
  }

  /// Builds the message input text field
  Widget _buildMessageInputField() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: _inputBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: TextField(
          controller: messageController,
          style: GoogleFonts.inter(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nhập tin nhắn...',
            hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.6)),
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
  Widget _buildSendButton() {
    return Container(
      decoration: const BoxDecoration(
        color: _primaryColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onSendPressed,
        icon: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }
}
