import 'package:flutter/material.dart';


import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';

import '../../../../chat_bot_view_home/presentation/pages/chat_bot_page.dart';

/// Bottom sheet menu showing more options for the scanned food detail
class MoreOptionsMenu extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;
  final VoidCallback onDelete;
  final bool showSaveToDevice;
  // Optional external handler; if not provided, a sensible default is used
  final VoidCallback? onAskChatBot;

  const MoreOptionsMenu({
    super.key,
    required this.scannedFood,
    required this.responsive,
    required this.onDelete,
    this.showSaveToDevice = true,
    this.onAskChatBot,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.chat_bubble_outline,
              color: Colors.blue,
            ),
            title: const Text('Ask chat bot'),
            onTap: () {
              // Close the sheet first
              Navigator.pop(context);

              // If an external handler is provided, use it.
              if (onAskChatBot != null) {
                onAskChatBot!();
                return;
              }

              // Otherwise, navigate to the ChatBotPage and pass the scanned food.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatBotPage(
                    initialFoodAnalysis: scannedFood,
                  ),
                ),
              );
            },
          ),
          if (showSaveToDevice)
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Save to device'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: Text(
              l10n?.delete ?? 'Delete',
              style: const TextStyle(color: Colors.red),
            ),
            onTap: () {
              // Close sheet then perform deletion without extra confirmation
              Navigator.pop(context);
              onDelete();
            },
          ),
        ],
      ),
    );
  }
}

