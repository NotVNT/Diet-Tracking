import 'package:flutter/material.dart';

/// Nutrient item with optional progress bar
/// Optimized for smooth performance with minimal rebuilds
class NutrientItem extends StatelessWidget {
  const NutrientItem({
    super.key,
    required this.title,
    required this.valueText,
    required this.progress,
    required this.color,
    this.icon,
    this.showProgress = true,
    this.valueStyle,
  });

  final String title;
  final String valueText;
  final double progress;
  final Color color;
  final String? icon; // Emoji icon like 🥩, 🍚
  final bool showProgress;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Show a tiny sliver of color even when progress is 0 for context
    final displayProgress = progress <= 0 ? 0.02 : progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title row with icon and value
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Title with icon
            Expanded(
              child: Row(
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(icon!, style: const TextStyle(fontSize: 18)),
                    ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Value text
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                valueText,
                style:
                    valueStyle ??
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
            ),
          ],
        ),
        if (showProgress) ...[
          const SizedBox(height: 6),
          // Progress bar with smooth animation - adaptive colors for dark/light mode
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value:
                  displayProgress, // Use displayProgress instead of raw progress
              minHeight: 8,
              backgroundColor: isDarkMode
                  ? theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    )
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ],
    );
  }
}
