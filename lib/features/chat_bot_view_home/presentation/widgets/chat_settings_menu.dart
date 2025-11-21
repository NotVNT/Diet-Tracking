import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';

/// Settings menu widget that appears when clicking the three-dot icon
class ChatSettingsMenu extends StatelessWidget {
  final VoidCallback? onCreateNewChat;
  final VoidCallback? onChatHistory;

  const ChatSettingsMenu({
    super.key,
    this.onCreateNewChat,
    this.onChatHistory,
    
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(
          context: context,
          value: 'new_chat',
          icon: Icons.add_comment_outlined,
          title: l10n.chatBotCreateNewChat,
          subtitle: l10n.chatBotStartNewConversation,
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          context: context,
          value: 'chat_history',
          icon: Icons.history_outlined,
          title: l10n.chatBotChatHistory,
          subtitle: l10n.chatBotViewPreviousConversations,
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'new_chat':
            onCreateNewChat?.call();
            break;
          case 'chat_history':
            onChatHistory?.call();
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required BuildContext context,
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
