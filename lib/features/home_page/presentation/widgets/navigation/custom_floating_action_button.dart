import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

/// Custom floating action button with action buttons
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onRecordSelected;
  final VoidCallback onChatBotSelected;
  final VoidCallback onScanFoodSelected;
  final VoidCallback onReportSelected;

  const CustomFloatingActionButton({
    super.key,
    required this.onRecordSelected,
    required this.onChatBotSelected,
    required this.onScanFoodSelected,
    required this.onReportSelected,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return FloatingActionButton(
      onPressed: () => _showActionButtons(context, localizations),
      backgroundColor: Colors.black,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  void _showActionButtons(BuildContext context, AppLocalizations? localizations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 2 Action buttons trên 1 hàng ngang
                Row(
                  children: [
                    // Action button cho Ghi nhận
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
                    const SizedBox(width: 12),
                    // Action button cho Chat bot
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
                const SizedBox(height: 12),
                // Action button cho Scan food và Report
                Row(
                  children: [
                    // Action button cho Scan food
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.qr_code_scanner,
                        label: localizations?.bottomNavScanFood ?? 'Quét món ăn',
                        onTap: () {
                          Navigator.pop(context);
                          onScanFoodSelected();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Action button cho Report
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.assessment_outlined,
                        label: localizations?.bottomNavReport ?? 'Báo cáo',
                        onTap: () {
                          Navigator.pop(context);
                          onReportSelected();
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                Icon(
                  icon,
                  size: 28,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
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
