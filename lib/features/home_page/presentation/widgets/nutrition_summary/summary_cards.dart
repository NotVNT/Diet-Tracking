import 'package:flutter/material.dart';

import '../../../domain/entities/nutrition_totals.dart';
import '../components/nutrient_color_scheme.dart';

class SummaryCards extends StatelessWidget {
  final NutritionTotals totals;

  const SummaryCards({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
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

    return Row(
      children: [
        Expanded(
          child: _infoCard(
            "Calories",
            totals.calories.toStringAsFixed(0),
            "kcal",
            Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _miniInfoCard(
                context,
                label: "Protein",
                value: "${totals.protein.toStringAsFixed(0)}g",
                color: proteinColor,
                icon: NutrientColorScheme.getEmoji(NutrientType.protein),
              ),
              const SizedBox(height: 8),
              _miniInfoCard(
                context,
                label: "Carbs",
                value: "${totals.carbs.toStringAsFixed(0)}g",
                color: carbsColor,
                icon: NutrientColorScheme.getEmoji(NutrientType.carbs),
              ),
              const SizedBox(height: 8),
              _miniInfoCard(
                context,
                label: "Fat",
                value: "${totals.fat.toStringAsFixed(0)}g",
                color: fatColor,
                icon: NutrientColorScheme.getEmoji(NutrientType.fat),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoCard(String label, String value, String unit, Color color) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 28)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            "$unit • $label",
            style: TextStyle(
              color: color.withAlpha(204),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniInfoCard(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required String icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
