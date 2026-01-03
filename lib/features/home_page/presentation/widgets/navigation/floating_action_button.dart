import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../utils/bottom_sheet_utils.dart';

/// Custom floating action button with action buttons
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onRecordSelected;
  final VoidCallback onChatBotSelected;
  final VoidCallback onScanFoodSelected;
  final VoidCallback onReportSelected;
  final VoidCallback onUploadVideoSelected;

  const CustomFloatingActionButton({
    super.key,
    required this.onRecordSelected,
    required this.onChatBotSelected,
    required this.onScanFoodSelected,
    required this.onReportSelected,
    required this.onUploadVideoSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: () => _showActionButtons(context, localizations),
      backgroundColor: isDark ? Colors.black : Colors.black,
      shape: const CircleBorder(),
      child: Icon(
        Icons.add,
        color: isDark ? Colors.white : Colors.white,
        size: 28,
      ),
    );
  }

  void _showActionButtons(
    BuildContext context,
    AppLocalizations? localizations,
  ) {
    showCustomBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Row 1: Upload Video & Record
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.video_call,
                        label: localizations?.analysisVideo ?? 'Phân tích video',
                        onTap: () {
                          Navigator.pop(context);
                          onUploadVideoSelected();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.edit_note,
                        label: localizations?.bottomNavRecord ?? 'Ghi nhận',
                        onTap: () {
                          Navigator.pop(context);
                          onRecordSelected();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Row 2: Scan Food & Chat Bot
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.qr_code_scanner,
                        label:
                            localizations?.bottomNavScanFood ?? 'Quét món ăn',
                        onTap: () {
                          Navigator.pop(context);
                          onScanFoodSelected();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: localizations?.bottomNavChatBot ?? 'Chat bot',
                        onTap: () {
                          Navigator.pop(context);
                          onChatBotSelected();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Widget cho action button với khung chữ nhật và viền bo tròn
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fgColor = isDark ? Colors.white : Colors.black87;

    if (isDark) {
      // Dark mode: dùng gradient như bạn đề xuất
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF424242), // Xám đậm (Grey 800)
              Color(0xFF212121), // Đen xám (Grey 900)
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 5,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              splashColor: Colors.white24,
              highlightColor: Colors.white10,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 28, color: fgColor),
                    const SizedBox(height: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: fgColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Light mode: giữ Material với nền trắng và đổ bóng nhẹ
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: fgColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: fgColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
