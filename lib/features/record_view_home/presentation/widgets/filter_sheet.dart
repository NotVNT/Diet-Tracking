import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../responsive/responsive.dart';
import 'calorie_filter.dart';
import 'date_range_filter.dart';

class FilterSheet extends StatefulWidget {
  final String? calorieRange;
  final DateTimeRange? dateRange;
  final void Function(String? calorieRange, DateTimeRange? dateRange) onApply;
  final VoidCallback? onClear;
  final ScrollController? scrollController; // for DraggableScrollableSheet

  const FilterSheet({
    super.key,
    this.calorieRange,
    this.dateRange,
    required this.onApply,
    this.onClear,
    this.scrollController,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  String? _selectedCalorieRange;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _selectedCalorieRange = widget.calorieRange;
    _selectedDateRange = widget.dateRange;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final r = ResponsiveHelper.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        controller: widget.scrollController,
        child: Padding(
          padding: EdgeInsets.only(
            left: r.width(16),
            right: r.width(16),
            bottom: r.height(16),
            top: r.height(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t?.filterTitle ?? 'Bộ lọc',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              SizedBox(height: r.height(8)),
              // Date range section
              Container(
                padding: EdgeInsets.all(r.width(12)),
                decoration: BoxDecoration(
                  color: isDark
                      ? cs.surfaceContainerHighest.withValues(alpha: 0.18)
                      : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: (isDark ? cs.outline.withValues(alpha: 0.6) : cs.outlineVariant.withValues(alpha: 0.5))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t?.dateRangeTitle ?? 'Khoảng ngày',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: r.height(8)),
                    DateRangeFilter(
                      initialRange: _selectedDateRange,
                      onChanged: (range) => setState(() => _selectedDateRange = range),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.height(12)),
              // Calorie range section
              Container(
                padding: EdgeInsets.all(r.width(12)),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: theme.brightness == Brightness.dark ? 0.18 : 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t?.calorieRangeLabel ?? 'Khoảng calo',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                    ),
                    SizedBox(height: r.height(8)),
                    CalorieFilter(
                      initialSelected: _selectedCalorieRange,
                      onFilterChanged: (val) => setState(() => _selectedCalorieRange = val),
                    ),
                  ],
                ),
              ),
              SizedBox(height: r.height(16)),
              // Actions
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onClear?.call();
                      setState(() {
                        _selectedCalorieRange = null;
                        _selectedDateRange = null;
                      });
                    },
                    child: Text(t?.reset ?? 'Đặt lại'),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: r.width(18), vertical: r.height(12)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    onPressed: () {
                      widget.onApply(_selectedCalorieRange, _selectedDateRange);
                      Navigator.of(context).pop();
                    },
                    child: Text(t?.apply ?? 'Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

