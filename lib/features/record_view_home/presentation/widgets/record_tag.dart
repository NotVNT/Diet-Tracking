import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/food_record_entity.dart';
import '../../../../common/app_styles.dart';

class RecordTag extends StatelessWidget {
  const RecordTag({super.key, required this.record});

  final FoodRecordEntity record;

  @override
  Widget build(BuildContext context) {
    final isBot = record.recordType == RecordType.text;
    // Scanned if barcode OR (food type AND has image)
    final isScanned =
        record.recordType == RecordType.barcode ||
        (record.recordType == RecordType.food &&
            (record.imagePath ?? '').isNotEmpty);

    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    late final IconData icon;
    late final String label;
    if (isBot) {
      icon = Icons.smart_toy_outlined;
      label = l10n?.sourceTagBotSuggestion ?? 'Gợi ý Chatbot';
    } else if (isScanned) {
      icon = Icons.camera_alt_outlined;
      label = l10n?.sourceTagScanned ?? 'Từ quét ảnh/mã';
    } else {
      // Default to manual for any other case
      icon = Icons.edit_outlined;
      label = l10n?.sourceTagManual ?? 'Nhập thủ công';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppStyles.bodySmall.copyWith(
              fontSize: 11,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
