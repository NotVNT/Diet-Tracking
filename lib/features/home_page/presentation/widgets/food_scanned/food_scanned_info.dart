import 'package:flutter/material.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../components/nutrient_color_scheme.dart';

class FoodScannedInfo extends StatelessWidget {
  final FoodRecordEntity record;
  final bool showTime;
  final bool emphasizeCalories;
  final bool approxForBotSuggestion;
  final String? caloriesSuffix;
  final bool showMacros;

  const FoodScannedInfo({
    super.key,
    required this.record,
    this.showTime = true,
    this.emphasizeCalories = true,
    this.approxForBotSuggestion = false,
    this.caloriesSuffix,
    this.showMacros = true,
  });

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _foodNameOrFallback() {
    final name = record.foodName.trim();
    if (name.isEmpty) return 'No Food Detection';
    return name;
  }

  /// Try to extract a displayed calorie range from the record's detail text.
  ///
  /// We keep `record.calories` as a numeric value for daily totals, but when the
  /// backend provides a range we want to show it as "min - max kcal" in the
  /// scanned item UI.
  String? _tryExtractCalorieRangeLabel() {
    final raw = (record.nutritionDetails ?? '').trim();
    if (raw.isEmpty) return null;

    // Examples we support:
    // - "🔥 Calories (ước tính): 450 - 600 kcal"
    // - "Khoảng calories ước tính: 450 - 600 kcal"
    // - "Calories: Khoảng (450) - (600) kcal" (best-effort)
    final m = RegExp(
      r'(?:calo(?:ries)?)[^\d]{0,20}(\d{2,5})\s*[-–]\s*(\d{2,5})\s*k?cal',
      caseSensitive: false,
    ).firstMatch(raw);
    if (m == null) return null;
    return '${m.group(1)} - ${m.group(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool hasAnyMacro =
        record.protein != null || record.carbs != null || record.fat != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _foodNameOrFallback(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showTime) ...[
              const SizedBox(width: 8),
              _TimeBadge(text: _formatTime(record.date)),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              NutrientColorScheme.getEmoji(NutrientType.calorie),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              _buildCaloriesLabel(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: emphasizeCalories
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
        if (showMacros && hasAnyMacro) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              _MacroChip(
                emoji: NutrientColorScheme.getEmoji(NutrientType.protein),
                label: _formatGram(record.protein),
              ),
              const SizedBox(width: 12),
              _MacroChip(
                emoji: NutrientColorScheme.getEmoji(NutrientType.carbs),
                label: _formatGram(record.carbs),
              ),
              const SizedBox(width: 12),
              _MacroChip(
                emoji: NutrientColorScheme.getEmoji(NutrientType.fat),
                label: _formatGram(record.fat),
              ),
            ],
          ),
        ],
      ],
    );
  }

  String _formatGram(double? value) {
    if (value == null) return 'N/A g';
    return '${value.toStringAsFixed(0)} g';
  }

  String _buildCaloriesLabel() {
    final range = _tryExtractCalorieRangeLabel();
    if (range != null) {
      return '$range ${caloriesSuffix ?? 'kcal'}';
    }

    // Default: show numeric calories.
    final prefix =
        (approxForBotSuggestion && (record.nutritionDetails?.trim().isNotEmpty == true))
            ? '~'
            : '';
    return '$prefix${record.calories.toStringAsFixed(0)} ${caloriesSuffix ?? 'kcal'}';
  }
}

class _TimeBadge extends StatelessWidget {
  final String text;
  const _TimeBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final String emoji;
  final String label;

  const _MacroChip({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
