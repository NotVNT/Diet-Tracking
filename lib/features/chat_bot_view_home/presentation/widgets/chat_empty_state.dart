import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.onCreateNewChat,
    this.onShowHistory,
  });

  final VoidCallback onCreateNewChat;
  final VoidCallback? onShowHistory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colorScheme.primaryContainer,
                child: Icon(
                  Icons.forum_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.chatBotEmptyTitle,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.chatBotEmptySubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: textTheme.bodySmall?.color),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (onShowHistory != null)
                    OutlinedButton.icon(
                      onPressed: onShowHistory,
                      icon: const Icon(Icons.history),
                      label: Text(l10n.chatBotChatHistory),
                    ),
                  if (onShowHistory != null) const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: onCreateNewChat,
                    icon: const Icon(Icons.add_comment_outlined),
                    label: Text(l10n.chatBotCreateNewChat),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

