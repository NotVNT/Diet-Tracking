import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../data/parsers/food_suggestion_parser.dart';
import '../../../record_view_home/presentation/cubit/record_cubit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../services/user_avatar_service.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';

/// Widget for displaying chat message bubbles
class ChatMessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
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
    return Builder(
      builder: (context) {
        if (isUser) {
          // Use cached user avatar with graceful fallbacks
          final provider = UserAvatarService.instance.imageProvider;
          return CircleAvatar(radius: 16, backgroundImage: provider);
        }
        // Bot avatar remains an icon with themed background
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
        );
      },
    );
  }

  /// Builds the message content with text and timestamp
  Widget _buildMessageContent() {
    final suggestions = FoodSuggestionParser.extract(message.text);

    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
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
            ..._buildContentWidgets(context),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp, context),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: message.isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
            ),
            if (!message.isUser && suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildAddToRecordsActions(suggestions),
            ],
          ],
        ),
      ),
    );
  }

  /// Formats timestamp for display
  String _formatTime(DateTime timestamp, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return l10n.chatBotJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.chatBotMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.chatBotHoursAgo(difference.inHours);
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  // Build actions for multiple suggestions: per-item save + save all
  Widget _buildAddToRecordsActions(List<FoodSuggestion> suggestions) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (suggestions.length > 1)
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final recordCubit = context.read<RecordCubit>();

                      final records = suggestions
                          .map(
                            (s) => FoodRecordEntity(
                              foodName: s.foodName,
                              calories: s.calories,
                              nutritionDetails: s.nutritionDetails,
                              reason: s.reason,
                              date: DateTime.now(),
                              recordType: RecordType.text,
                            ),
                          )
                          .toList();

                      await recordCubit.saveMultipleFoodRecords(records);
                    },
                    icon: const Icon(
                      Icons.playlist_add,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text(
                      l10n.chatBotSaveAll,
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
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
                    final recordCubit = context.read<RecordCubit>();
                    await recordCubit.saveFoodRecord(
                      s.foodName,
                      s.calories,
                      nutritionDetails: s.nutritionDetails,
                      recordType: RecordType.text,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('${l10n.chatBotSave}: $label'),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildContentWidgets(BuildContext context) {
    if (message.isUser) {
      return [
        _buildRichText(context, message.text, isUser: true),
      ];
    }

    final lines = message.text.split('\n');
    final widgets = <Widget>[];
    var currentTextBuffer = StringBuffer();

    void flushBuffer() {
      if (currentTextBuffer.isNotEmpty) {
        widgets.add(_buildRichText(
          context,
          currentTextBuffer.toString().trim(),
        ));
        widgets.add(const SizedBox(height: 12));
        currentTextBuffer.clear();
      }
    }

    for (var line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith(RegExp(r'^[\*\-]\s'))) {
        flushBuffer();
        String content = trimmedLine.replaceFirst(RegExp(r'^[\*\-]\s'), '');
        widgets.add(_buildCardItem(context, content));
        widgets.add(const SizedBox(height: 12));
      } else if (trimmedLine.startsWith(RegExp(
          r'^(Lưu ý|Mẹo|Gợi ý|Lời khuyên|Kết luận|Chú ý)',
          caseSensitive: false))) {
        flushBuffer();
        widgets.add(Text(
          trimmedLine,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ));
        widgets.add(const SizedBox(height: 8));
      } else {
        currentTextBuffer.writeln(line);
      }
    }

    flushBuffer();

    if (widgets.isNotEmpty && widgets.last is SizedBox) {
      widgets.removeLast();
    }

    return widgets;
  }

  Widget _buildCardItem(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: _buildRichText(context, content),
    );
  }

  Widget _buildRichText(BuildContext context, String text,
      {bool isUser = false}) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*\*(.*?)\*\*');
    int lastIndex = 0;

    final baseStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
          height: 1.5, // Increased line height for better readability
        );

    final boldStyle = baseStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: isUser ? Colors.white : Theme.of(context).colorScheme.primary,
    );

    for (final match in regex.allMatches(text)) {
      if (match.start > lastIndex) {
        parts.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }
      parts.add(TextSpan(
        text: match.group(1),
        style: boldStyle,
      ));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      parts.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: parts),
    );
  }
}
