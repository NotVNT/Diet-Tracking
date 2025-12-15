import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../chat_bot_view_home/presentation/providers/chat_provider_factory.dart';
import '../../../../home_page/presentation/providers/home_provider.dart';
import '../../../../../config/home_page_config.dart';

/// Bottom sheet menu showing more options for the scanned food detail
class MoreOptionsMenu extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;
  final VoidCallback onDelete;
  final bool showSaveToDevice;
  // Optional external handler; if not provided, a sensible default is used
  final VoidCallback? onAskChatBot;
  // Optional: close parent page (e.g., detail page) after choosing Ask chat bot
  final VoidCallback? onCloseParent;

  const MoreOptionsMenu({
    super.key,
    required this.scannedFood,
    required this.responsive,
    required this.onDelete,
    this.showSaveToDevice = true,
    this.onAskChatBot,
    this.onCloseParent,
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

              // Otherwise: close parent page if provided, switch to Chat tab, then send analysis
              () async {
                // Close parent page (e.g., detail page) to reveal main scaffold with bottom nav
                onCloseParent?.call();

                // Switch bottom navigation to ChatBot tab
                final homeProvider = context.read<HomeProvider>();
                await homeProvider.setCurrentIndex(HomePageConfig.chatBotIndex);

                // Ensure chat session exists, then send analysis
                final chatProvider = ChatProviderFactory.create();
                await chatProvider.initOrLoadRecentSession();
                if (chatProvider.currentSession == null) {
                  await chatProvider.createNewChatSession();
                }
                await chatProvider.sendFoodScanAnalysis(scannedFood);
              }();
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

