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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              '${(approxForBotSuggestion && (record.nutritionDetails?.trim().isNotEmpty == true)) ? "~" : ""}${record.calories.toStringAsFixed(0)} ${caloriesSuffix ?? 'kcal'}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: emphasizeCalories
                    ? FontWeight.w700
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
        if (showMacros) ...[
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
