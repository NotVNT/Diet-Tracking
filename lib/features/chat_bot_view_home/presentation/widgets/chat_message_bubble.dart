import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';

// Helper class for food suggestion data
class FoodSuggestion {
  final String foodName;
  final double calories;
  final String? reason; // Lý do chọn
  final String? nutritionDetails; // Khối "Thông tin dinh dưỡng"

  FoodSuggestion({
    required this.foodName,
    required this.calories,
    this.reason,
    this.nutritionDetails,
  });
}

/// Widget for displaying chat message bubbles
class ChatMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  static const Color _primaryColor = Color(0xFF4CAF50);
  static const Color _messageBubbleColor = Color(0xFF2D2D2D);
  static const double _borderRadius = 20.0;

  const ChatMessageBubble({super.key, required this.message});

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
    final suggestions = _extractFoodSuggestions(message.text);

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
          if (!message.isUser && suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAddToRecordsActions(suggestions),
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



  // Extract multiple suggestions strictly by "Món ăn đề xuất|gợi ý: <tên>" blocks
  List<FoodSuggestion> _extractFoodSuggestions(String text) {
    final lower = text.toLowerCase();
    final hasSuggestKeyword =
        lower.contains('món ăn đề xuất') || lower.contains('món ăn gợi ý');
    if (!hasSuggestKeyword) return [];

    final nameRx = RegExp(
      r'(Món ăn (?:đề xuất|gợi ý)[:：]?\s*)(.+)',
      caseSensitive: false,
    );

    final matches = nameRx.allMatches(text).toList();
    if (matches.isEmpty) return [];

    final suggestions = <FoodSuggestion>[];

    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final name = (m.group(2) ?? '').trim();
      if (name.isEmpty) continue;

      // Lấy đoạn text từ sau tên đến trước tên tiếp theo để tìm calo
      final start = m.end;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final slice = text.substring(start, end);

      final caloRxList = <RegExp>[
        RegExp(
          r'Calo[:：]?\s*[~≈]?(\d+)\s*[-–]\s*(\d+)\s*kcal',
          caseSensitive: false,
        ),
        RegExp(
          r'Calo[:：]?\s*Khoảng\s*(\d+)\s*-\s*(\d+)\s*kcal',
          caseSensitive: false,
        ),
        RegExp(r'Calo[:：]?\s*(\d+)\s*kcal', caseSensitive: false),
      ];
      double calories = 0;
      for (final rx in caloRxList) {
        final cm = rx.firstMatch(slice);
        if (cm != null) {
          final c1 = double.tryParse(cm.group(1) ?? '') ?? 0;
          final c2 =
              double.tryParse(
                (cm.groupCount >= 2 ? cm.group(2) : null) ?? '',
              ) ??
              0;
          calories = (c1 > 0 && c2 > 0) ? (c1 + c2) / 2 : (c1 > 0 ? c1 : c2);
          break;
        }
      }

      // Tách lý do và thông tin dinh dưỡng bằng regex linh hoạt (hỗ trợ **...** và xuống dòng)
      String? reason;
      String? nutrition;
      final reasonMatch = RegExp(
        r'\*\*\s*Lý do chọn\s*[:：]?\s*\*\*\s*([\s\S]*?)(?:\n\s*\*\*|\$)',
        caseSensitive: false,
      ).firstMatch(slice);
      if (reasonMatch != null) {
        reason = reasonMatch.group(1)?.trim();
      }
      RegExp _nutriRx1 = RegExp(
        r'(?:\*\*)?\s*Thông tin dinh dưỡng(?:\s*\([^)]*\))?\s*(?:\*\*)?\s*[:：]?\s*([\s\S]*)',
        caseSensitive: false,
      );
      RegExp _nutriRx2 = RegExp(
        r'(?:\*\*)?\s*Th\w*ng tin dinh d\w*(?:\s*\([^)]*\))?\s*(?:\*\*)?\s*[:：]?\s*([\s\S]*)',
        caseSensitive: false,
      );
      final nutritionMatch =
          _nutriRx1.firstMatch(slice) ?? _nutriRx2.firstMatch(slice);
      if (nutritionMatch != null) {
        nutrition = nutritionMatch.group(1)?.trim();
      }
      // Làm sạch ký tự ngôi sao trong nội dung dinh dưỡng, bỏ các dòng chỉ có sao
      if (nutrition != null) {
        final cleanedLines = nutrition
            .split('\n')
            .map((l) => l.replaceAll('⭐', '').trimRight())
            .where((l) => l.trim().isNotEmpty)
            .toList();
        nutrition = cleanedLines.join('\n');
      }
      // Fallback: nếu chưa bắt được, tách theo dòng sau tiêu đề và gom các dòng bullet
      if (nutrition == null || nutrition.trim().isEmpty) {
        final lines = slice.split('\n');
        bool inSection = false;
        final buff = <String>[];
        for (final raw in lines) {
          final l = raw.trimRight();
          final lower = l.toLowerCase();
          if (!inSection && lower.contains('thông tin dinh dưỡng')) {
            inSection = true;
            continue;
          }
          if (!inSection) continue;
          // Dừng khi gặp header mới hoặc dòng toàn '**'
          if (l.startsWith('**')) break;
          if (l.trim().isEmpty) continue;
          // Fallback 2: gom các dòng bullet thường gặp nếu vẫn chưa có
          if (nutrition == null || nutrition.trim().isEmpty) {
            final lines = slice.split('\n');
            bool afterHeader = false;
            final buff = <String>[];
            for (final raw in lines) {
              final l = raw.trimRight();
              final lower = l.toLowerCase();
              if (!afterHeader && lower.contains('thông tin dinh dưỡng')) {
                afterHeader = true;
                continue;
              }
              if (!afterHeader) continue;
              if (l.startsWith('**') || l.startsWith('⭐'))
                break; // kết thúc block
              if (l.trim().isEmpty) continue;
              final isBullet =
                  l.trimLeft().startsWith('-') ||
                  l.trimLeft().startsWith('•') ||
                  lower.contains('kcal') ||
                  lower.contains('protein') ||
                  lower.contains('carb') ||
                  lower.contains('fat');
              if (isBullet) buff.add(l);
            }
            if (buff.isNotEmpty) nutrition = buff.join('\n');
          }

          buff.add(l);
        }
        if (buff.isNotEmpty) {
          nutrition = buff.join('\n');
        }
      }

      // Chỉ thêm theo tên món; không thêm các block “Lý do chọn”, “Thông tin dinh dưỡng” vào tên
      final cleanedName = name.replaceAll(RegExp(r'\*\*'), '').trim();
      final ignoreLower = cleanedName.toLowerCase();
      if (ignoreLower.contains('thông tin dinh dưỡng') ||
          ignoreLower.contains('lý do chọn')) {
        continue;
      }

      final exists = suggestions.any(
        (e) => e.foodName.toLowerCase() == cleanedName.toLowerCase(),
      );
      if (!exists) {
        suggestions.add(
          FoodSuggestion(
            foodName: cleanedName,
            calories: calories,
            reason: reason,
            nutritionDetails: nutrition,
          ),
        );
      }
    }

    return suggestions;
  }

  // Build actions for multiple suggestions: per-item save + save all
  Widget _buildAddToRecordsActions(List<FoodSuggestion> suggestions) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (suggestions.length > 1)
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      for (final s in suggestions) {
                        await context.read<RecordCubit>().saveFoodRecord(
                          s.foodName,
                          s.calories,
                          nutritionDetails: s.nutritionDetails,
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Đã thêm ${suggestions.length} món vào danh sách',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      'Lưu tất cả',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: suggestions.map((s) {
                final label = s.foodName.length > 18
                    ? '${s.foodName.substring(0, 18)}…'
                    : s.foodName;
                return OutlinedButton(
                  onPressed: () async {
                    await context.read<RecordCubit>().saveFoodRecord(
                      s.foodName,
                      s.calories,
                      nutritionDetails: s.nutritionDetails,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm "${s.foodName}" vào danh sách'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _primaryColor),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Lưu: $label'),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
