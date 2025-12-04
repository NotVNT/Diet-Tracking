import 'package:flutter/material.dart';
import '../../../../common/app_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home_page/presentation/widgets/food_scanned/food_scanned_info.dart';
import '../../domain/entities/food_record_entity.dart';

class RecordDetailsSheet extends StatelessWidget {
  const RecordDetailsSheet({super.key, required this.record});

  final FoodRecordEntity record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: FoodScannedInfo(
                    record: record,
                    showTime: false,
                    emphasizeCalories: true,
                    approxForBotSuggestion: true,
                    caloriesSuffix: l10n?.calories ?? 'calories',
                    showMacros: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if ((record.nutritionDetails ?? '').trim().isNotEmpty) ...[
              Text(
                l10n?.nutritionInfo ?? 'Thông tin dinh dưỡng',
                style: AppStyles.heading2.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                record.nutritionDetails!.trim(),
                style: AppStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

