import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../l10n/app_localizations.dart';

/// Widget for chat options popup menu
class ChatOptionsPopup extends StatelessWidget {
  final Function(String) onOptionSelected;
  
  static const Color _messageBubbleColor = Color(0xFF2D2D2D);
  static const double _smallBorderRadius = 12.0;

  const ChatOptionsPopup({
    super.key,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final menuOptions = [
      {'icon': Icons.attach_file, 'title': l10n.chatBotFoodSuggestion, 'color': Colors.white},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _messageBubbleColor,
        borderRadius: BorderRadius.circular(_smallBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(77), // 0.3 * 255
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: menuOptions
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
        onTap: () => onOptionSelected(option['title'] as String),
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
}
