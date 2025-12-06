import 'package:flutter/material.dart';
import '../../../../common/app_styles.dart';
import '../../../../l10n/app_localizations.dart';

class CalorieFilter extends StatefulWidget {
  final Function(String?) onFilterChanged;
  final String? initialSelected;

  const CalorieFilter({
    super.key,
    required this.onFilterChanged,
    this.initialSelected,
  });

  @override
  State<CalorieFilter> createState() => _CalorieFilterState();
}

class _CalorieFilterState extends State<CalorieFilter> {
  String? selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialSelected;
  }

  @override
  void didUpdateWidget(covariant CalorieFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSelected != widget.initialSelected) {
      setState(() {
        selectedFilter = widget.initialSelected;
      });
    }
  }

  final List<Map<String, dynamic>> filterOptions = const [
    {'label': '0-250 Cal', 'value': '0-250', 'min': 0, 'max': 250},
    {'label': '250-500 Cal', 'value': '250-500', 'min': 250, 'max': 500},
    {'label': '500-800 Cal', 'value': '500-800', 'min': 500, 'max': 800},
    {'label': '800-1200 Cal', 'value': '800-1200', 'min': 800, 'max': 1200},
    {'label': '1200-1600 Cal', 'value': '1200-1600', 'min': 1200, 'max': 1600},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final t = AppLocalizations.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // All chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selectedFilter == null,
              label: Text(
                t?.all ?? 'All',
                style: AppStyles.bodyMedium.copyWith(
                  color: selectedFilter == null ? cs.onPrimary : cs.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              avatar: selectedFilter == null ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary) : null,
              onSelected: (_) {
                setState(() => selectedFilter = null);
                widget.onFilterChanged(null);
              },
              backgroundColor: selectedFilter == null ? cs.primary : (isDark ? Colors.transparent : cs.surfaceContainerHigh),
              selectedColor: cs.primary,
              side: BorderSide(color: selectedFilter == null ? Colors.transparent : (isDark ? cs.outline.withValues(alpha: 0.6) : cs.outlineVariant), width: isDark ? 1.2 : 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              visualDensity: VisualDensity.compact,
            ),
          ),
          ...filterOptions.map((option) {
            final isSelected = selectedFilter == option['value'];
            final borderColor = isSelected
                ? Colors.transparent
                : (isDark ? cs.outline.withValues(alpha: 0.6) : cs.outlineVariant);
            final labelColor = isSelected ? cs.onPrimary : cs.onSurface;
            final bg = isSelected
                ? cs.primary
                : (isDark ? Colors.transparent : cs.surfaceContainerHigh);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: isSelected,
                label: Text(
                  option['label'],
                  style: AppStyles.bodyMedium.copyWith(
                    color: labelColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                avatar: isSelected ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary) : null,
                onSelected: (bool selected) {
                  setState(() {
                    selectedFilter = selected ? option['value'] as String : null;
                  });
                  widget.onFilterChanged(selectedFilter);
                },
                backgroundColor: bg,
                selectedColor: cs.primary,
                side: BorderSide(color: borderColor, width: isDark ? 1.2 : 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                visualDensity: VisualDensity.compact,
              ),
            );
          }),
        ],
      ),
    );
  }
}