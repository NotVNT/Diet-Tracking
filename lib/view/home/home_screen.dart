import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Data model for chat messages
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Home screen with chatbox interface for diet tracking assistance
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Constants
  static const Color _primaryColor = Color(0xFF4CAF50);
  static const Color _backgroundColor = Color(0xFF1A1A1A);
  static const Color _messageBubbleColor = Color(0xFF2D2D2D);
  static const Color _inputBackgroundColor = Color(0xFF2D2D2D);
  static const double _borderRadius = 20.0;
  static const double _smallBorderRadius = 12.0;
  // static const Duration _botResponseDelay = Duration(seconds: 1);

  // Controllers and state
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Xin chào! Tôi có thể giúp gì cho bạn hôm nay?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];
  bool _showOptions = false;

  // Option configurations
  static const List<Map<String, dynamic>> _menuOptions = [
    {
      'icon': Icons.attach_file,
      'title': 'Add photos & files',
      'color': Colors.white,
    },
    {
      'icon': Icons.cloud_upload,
      'title': 'Add from Google Drive',
      'color': Color(0xFF4285F4),
    },
    {'icon': Icons.image, 'title': 'Create image', 'color': Colors.white},
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Think longer',
      'color': Colors.white,
    },
    {'icon': Icons.search, 'title': 'Deep research', 'color': Colors.white},
    {
      'icon': Icons.menu_book,
      'title': 'Study and learn',
      'color': Colors.white,
    },
    {
      'icon': Icons.more_horiz,
      'title': 'More',
      'color': Colors.white,
      'hasArrow': true,
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildMessagesArea(),
          if (_showOptions) _buildOptionsPopup(),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Builds the app bar with title and settings button
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      title: Text(
        'Diet Assistant',
        style: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: _onSettingsPressed,
        ),
      ],
    );
  }

  /// Builds the scrollable messages area
  Widget _buildMessagesArea() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageBubble(message);
        },
      ),
    );
  }

  /// Builds a message bubble for the chat
  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            _buildAvatar(isUser: false),
            const SizedBox(width: 8),
          ],
          Flexible(child: _buildMessageContent(message)),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(isUser: true),
          ],
        ],
      ),
    );
  }

  /// Builds user or bot avatar
  Widget _buildAvatar({required bool isUser}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: _primaryColor, shape: BoxShape.circle),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  /// Builds the message content with text and timestamp
  Widget _buildMessageContent(ChatMessage message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: message.isUser ? _primaryColor : _messageBubbleColor,
        borderRadius: BorderRadius.circular(_borderRadius).copyWith(
          bottomLeft: message.isUser
              ? const Radius.circular(_borderRadius)
              : const Radius.circular(4),
          bottomRight: message.isUser
              ? const Radius.circular(4)
              : const Radius.circular(_borderRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.text,
            style: GoogleFonts.inter(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(message.timestamp),
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the options popup menu
  Widget _buildOptionsPopup() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _messageBubbleColor,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: _menuOptions
            .map((option) => _buildOptionItem(option))
            .toList(),
      ),
    );
  }

  /// Builds individual option item in the popup menu
  Widget _buildOptionItem(Map<String, dynamic> option) {
    final hasArrow = option['hasArrow'] as bool? ?? false;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onOptionSelected(option['title'] as String),
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                option['icon'] as IconData,
                color: option['color'] as Color,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option['title'] as String,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hasArrow)
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the input area with text field and send button
  Widget _buildInputArea() {
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
      onPressed: _toggleOptions,
      icon: Icon(_showOptions ? Icons.close : Icons.add, color: Colors.white),
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
          controller: _messageController,
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
          onSubmitted: _onMessageSubmitted,
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
        onPressed: _onSendPressed,
        icon: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }

  // Event Handlers

  /// Handles settings button press
  void _onSettingsPressed() {
    // TODO: Show settings menu
  }

  /// Toggles the options popup visibility
  void _toggleOptions() {
    setState(() {
      _showOptions = !_showOptions;
    });
  }

  /// Handles message submission from text field
  void _onMessageSubmitted(String text) {
    if (text.trim().isNotEmpty) {
      _sendMessage(text.trim());
    }
  }

  /// Handles send button press
  void _onSendPressed() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _sendMessage(text);
    }
  }

  /// Handles option selection from popup menu
  void _onOptionSelected(String option) {
    setState(() {
      _showOptions = false;
    });
    _handleOptionTap(option);
  }

  // Helper Methods

  /// Formats timestamp for display
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  /// Sends a message and simulates bot response
  void _sendMessage(String text) async {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _showOptions = false;
    });

    final botReply = await fetchGeminiReply((text));

    if (mounted) {
      setState(() {
        _messages.add(
          ChatMessage(text: botReply, isUser: false, timestamp: DateTime.now()),
        );
      });
    }
  }

  Future<String> fetchGeminiReply(String prompt) async {
    final url = Uri.parse('http://127.0.0.1:8000/chat');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "age": 18,
        "height": 171,
        "weight": 65,
        "disease": "thừa cân",
        "allergy": "sữa",
        "goal": "giảm cân",
        "prompt": prompt,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['reply'] ?? 'Không có phản hồi từ AI';
    } else {
      return 'Lỗi kết nối API';
    }
  }

  /// Simulates bot response after a delay
  // void _simulateBotResponse(String userMessage) {
  //   Future.delayed(_botResponseDelay, () {
  //     if (mounted) {
  //       setState(() {
  //         _messages.add(
  //           ChatMessage(
  //             text:
  //                 'Tôi đã nhận được tin nhắn của bạn: "$userMessage". Tôi sẽ giúp bạn với chế độ ăn kiêng!',
  //             isUser: false,
  //             timestamp: DateTime.now(),
  //           ),
  //         );
  //       });
  //     }
  //   });
  // }

  /// Handles option tap and generates appropriate response
  void _handleOptionTap(String option) {
    final response = _getOptionResponse(option);

    setState(() {
      _messages.add(
        ChatMessage(text: response, isUser: false, timestamp: DateTime.now()),
      );
    });
  }

  /// Returns appropriate response for each option
  String _getOptionResponse(String option) {
    switch (option) {
      case 'Add photos & files':
        return 'Bạn có thể thêm ảnh món ăn để tôi phân tích dinh dưỡng!';
      case 'Add from Google Drive':
        return 'Kết nối Google Drive để lưu trữ kế hoạch ăn kiêng của bạn!';
      case 'Create image':
        return 'Tôi có thể tạo hình ảnh minh họa cho kế hoạch ăn kiêng!';
      case 'Think longer':
        return 'Tôi sẽ suy nghĩ kỹ hơn về vấn đề của bạn...';
      case 'Deep research':
        return 'Tôi sẽ nghiên cứu sâu về chủ đề dinh dưỡng này!';
      case 'Study and learn':
        return 'Hãy cùng học về dinh dưỡng và sức khỏe!';
      case 'More':
        return 'Có thêm nhiều tùy chọn khác cho bạn!';
      default:
        return 'Tôi không hiểu tùy chọn này.';
    }
  }
}
