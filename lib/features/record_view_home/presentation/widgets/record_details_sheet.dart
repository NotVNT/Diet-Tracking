import 'package:flutter/material.dart';
import '../../../../common/app_styles.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../home_page/presentation/widgets/food_scanned/food_scanned_info.dart';
import '../../domain/entities/food_record_entity.dart';

class RecordDetailsSheet extends StatelessWidget {
  const RecordDetailsSheet({super.key, required this.record});

  final FoodRecordEntity record;

  String _filteredNutritionDetails(String raw) {
    // The scanner flow already shows the calorie range in the header.
    // Remove the redundant sentence to avoid duplicate UI lines.
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .map((e) => e.trimRight())
        .where((e) => e.trim().isNotEmpty)
        .toList();

    final filtered = lines
        .where(
          (l) =>
              !l.toLowerCase().startsWith('khoảng calories ước tính:'),
        )
        .toList();

    return filtered.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final rawDetails = (record.nutritionDetails ?? '').trim();
    final details = _filteredNutritionDetails(rawDetails);

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
            if (details.isNotEmpty) ...[
              Text(
                l10n?.nutritionInfo ?? 'Thông tin dinh dưỡng',
                style: AppStyles.heading2.copyWith(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                details,
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

