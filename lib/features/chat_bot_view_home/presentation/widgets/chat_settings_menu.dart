import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Settings menu widget that appears when clicking the three-dot icon
class ChatSettingsMenu extends StatelessWidget {
  final VoidCallback? onCreateNewChat;
  final VoidCallback? onChatHistory;
  final VoidCallback? onSettings;

  const ChatSettingsMenu({
    super.key,
    this.onCreateNewChat,
    this.onChatHistory,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      color: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 40),
      itemBuilder: (BuildContext context) => [
        _buildMenuItem(
          value: 'new_chat',
          icon: Icons.add_comment_outlined,
          title: 'Tạo đoạn chat mới',
          subtitle: 'Bắt đầu cuộc trò chuyện mới',
        ),
        _buildMenuItem(
          value: 'chat_history',
          icon: Icons.history_outlined,
          title: 'Lịch sử chat',
          subtitle: 'Xem các cuộc trò chuyện trước',
        ),
        const PopupMenuDivider(),
        _buildMenuItem(
          value: 'settings',
          icon: Icons.settings_outlined,
          title: 'Cài đặt',
          subtitle: 'Tùy chỉnh ứng dụng',
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
          case 'settings':
            onSettings?.call();
            break;
        }
      },
    );
  }

  PopupMenuItem<String> _buildMenuItem({
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
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
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: Colors.grey[400],
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
