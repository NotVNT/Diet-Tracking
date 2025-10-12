import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';

// Helper class for food suggestion data
class FoodSuggestion {
  final String foodName;
  final double calories;

  FoodSuggestion({required this.foodName, required this.calories});
}

/// Widget for displaying chat message bubbles
class ChatMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  static const Color _primaryColor = Color(0xFF4CAF50);
  static const Color _messageBubbleColor = Color(0xFF2D2D2D);
  static const double _borderRadius = 20.0;

  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
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
          Flexible(child: _buildMessageContent()),
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
      decoration: const BoxDecoration(
        color: _primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isUser ? Icons.person : Icons.smart_toy,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  /// Builds the message content with text and timestamp
  Widget _buildMessageContent() {
    final foodSuggestion = _extractFoodSuggestion(message.text);

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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          if (!message.isUser && foodSuggestion != null) ...[
            const SizedBox(height: 8),
            _buildAddToRecordsButton(foodSuggestion),
          ],
        ],
      ),
    );
  }

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

  // Extracts food suggestion from message text
  FoodSuggestion? _extractFoodSuggestion(String text) {
    final foodNameRegex = RegExp(r'Món ăn đề xuất: (.*)');
    final caloriesRegex = RegExp(r'-Calo: Khoảng (\d+) - (\d+) kcal');

    final foodNameMatch = foodNameRegex.firstMatch(text);
    final caloriesMatch = caloriesRegex.firstMatch(text);

    if (foodNameMatch != null && caloriesMatch != null) {
      final foodName = foodNameMatch.group(1)!.trim();
      final minCalories = double.parse(caloriesMatch.group(1)!);
      final maxCalories = double.parse(caloriesMatch.group(2)!);
      final avgCalories = (minCalories + maxCalories) / 2;

      return FoodSuggestion(foodName: foodName, calories: avgCalories);
    }

    return null;
  }

  // Builds the "Add to records" button
  Widget _buildAddToRecordsButton(FoodSuggestion suggestion) {
    return Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () {
          context.read<RecordCubit>().saveFoodRecord(
                suggestion.foodName,
                suggestion.calories,
              );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm "${suggestion.foodName}" vào danh sách'),
              backgroundColor: Colors.green,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Thêm vào danh sách',
          style: TextStyle(color: Colors.white),
        ),
      );
    });
  }
}
