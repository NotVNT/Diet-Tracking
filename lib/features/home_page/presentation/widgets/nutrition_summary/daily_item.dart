import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/nutrition_totals.dart';
import '../components/nutrient_color_scheme.dart';

class DailyItem extends StatelessWidget {
  final DateTime date;
  final NutritionTotals totals;

  const DailyItem({super.key, required this.date, required this.totals});

  @override
  Widget build(BuildContext context) {
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final proteinColor = NutrientColorScheme.getColor(
      NutrientType.protein,
      isDarkMode: isDark,
    );
    final carbsColor = NutrientColorScheme.getColor(
      NutrientType.carbs,
      isDarkMode: isDark,
    );
    final fatColor = NutrientColorScheme.getColor(
      NutrientType.fat,
      isDarkMode: isDark,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday
              ? theme.colorScheme.primary.withValues(alpha: 0.5)
              : theme.colorScheme.outlineVariant,
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Date Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE', 'vi').format(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isToday
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  DateFormat('dd').format(date),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isToday
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${totals.calories.toStringAsFixed(0)} kcal",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _nutrientText(
                      NutrientColorScheme.getEmoji(NutrientType.protein),
                      totals.protein,
                      proteinColor,
                    ),
                    const SizedBox(width: 12),
                    _nutrientText(
                      NutrientColorScheme.getEmoji(NutrientType.carbs),
                      totals.carbs,
                      carbsColor,
                    ),
                    const SizedBox(width: 12),
                    _nutrientText(
                      NutrientColorScheme.getEmoji(NutrientType.fat),
                      totals.fat,
                      fatColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientText(String icon, double value, Color color) {
    return Text(
      "$icon ${value.toStringAsFixed(0)}g",
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
    );
  }
}
