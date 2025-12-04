import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';

/// Dialog to confirm deletion of a scanned food item
class DeleteConfirmationDialog extends StatelessWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(localizations?.deletePhoto ?? 'Delete Photo'),
      content: Text(
        localizations?.deletePhotoConfirmation ??
            'Are you sure you want to delete this photo?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(localizations?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: Text(localizations?.delete ?? 'Delete'),
        ),
      ],
    );
  }
}
