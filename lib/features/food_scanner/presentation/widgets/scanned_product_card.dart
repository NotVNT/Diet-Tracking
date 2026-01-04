import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_state.dart';
import 'package:diet_tracking_project/features/home_page/presentation/widgets/components/nutrient_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class ScannedProductCard extends StatelessWidget {
  final BarcodeResolved state;
  final VoidCallback onReset;

  const ScannedProductCard({
    super.key,
    required this.state,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final product = state.product;
    final theme = Theme.of(context);
    final isDark = theme.colorScheme.brightness == Brightness.dark;
    final String title = product.productName ?? 'Unknown product';
    final String subtitle =
        (product.brands != null && product.brands!.isNotEmpty)
        ? product.brands!.trim()
        : '';
    final String calories = _formatCalories(product.calories);
    final String protein = _formatMacro(product.protein);
    final String carbs = _formatMacro(product.carbohydrates);
    final String fat = _formatMacro(product.fat);
    final String botResponse = (product.botResponse ?? '').trim();

    final macroChips = [
      _MacroChip(
        emoji: NutrientColorScheme.getEmoji(NutrientType.calorie),
        label: 'Calories',
        value: calories,
        accent: NutrientColorScheme.getColor(
          NutrientType.calorie,
          isDarkMode: isDark,
        ),
      ),
      _MacroChip(
        emoji: NutrientColorScheme.getEmoji(NutrientType.carbs),
        label: 'Carbs',
        value: carbs,
        accent: NutrientColorScheme.getColor(
          NutrientType.carbs,
          isDarkMode: isDark,
        ),
      ),
      _MacroChip(
        emoji: NutrientColorScheme.getEmoji(NutrientType.protein),
        label: 'Protein',
        value: protein,
        accent: NutrientColorScheme.getColor(
          NutrientType.protein,
          isDarkMode: isDark,
        ),
      ),
      _MacroChip(
        emoji: NutrientColorScheme.getEmoji(NutrientType.fat),
        label: 'Fat',
        value: fat,
        accent: NutrientColorScheme.getColor(
          NutrientType.fat,
          isDarkMode: isDark,
        ),
      ),
    ];

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Calories & macros',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: macroChips,
            ),
            if (botResponse.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        botResponse,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.85,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.read<BarcodeBloc>().add(
                        SaveBarcodeProductRequested(
                          product,
                          imagePath: state.imagePath,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ghi nhận thực phẩm'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                  ),
                  child: const Text('Bỏ qua'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatMacro(double? value) {
    if (value == null) return 'N/A g';
    return '${value.toStringAsFixed(0)} g';
  }

  String _formatCalories(double? value) {
    if (value == null) return '-';
    return '${value.toStringAsFixed(0)} kcal';
  }
}

class _MacroChip extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color accent;

  const _MacroChip({
    required this.emoji,
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 90),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
