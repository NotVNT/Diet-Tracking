import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../../../common/app_confirm_dialog.dart';

/// Bottom sheet menu showing more options for the scanned food detail
class MoreOptionsMenu extends StatelessWidget {
  final FoodRecordEntity scannedFood;
  final ResponsiveHelper responsive;
  final VoidCallback onDelete;
  final bool showSaveToDevice;

  const MoreOptionsMenu({
    super.key,
    required this.scannedFood,
    required this.responsive,
    required this.onDelete,
    this.showSaveToDevice = true,
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
              Navigator.pop(context);
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
            onTap: () async {
              // Capture navigator before async gap to avoid using context later
              final navigator = Navigator.of(context);
              // Show localized confirmation dialog above the sheet
              final confirmed = await showAppConfirmDialog(
                context,
                title: l10n?.deletePhoto ?? 'Delete Photo',
                message: l10n?.deletePhotoConfirmation ??
                    'Are you sure you want to delete this photo?',
                confirmText: l10n?.delete,
                cancelText: l10n?.cancel,
                destructive: true,
                icon: Icons.delete_rounded,
              );
              if (confirmed == true) {
                // Close sheet then perform deletion
                navigator.pop();
                onDelete();
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Dialog to confirm deletion of a scanned food item
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AppConfirmDialog(
      title: localizations?.deletePhoto ?? 'Delete Photo',
      message: localizations?.deletePhotoConfirmation ??
          'Are you sure you want to delete this photo?',
      confirmText: localizations?.delete ?? 'Delete',
      cancelText: localizations?.cancel ?? 'Cancel',
      destructive: true,
      icon: Icons.delete_rounded,
    );
  }
}

