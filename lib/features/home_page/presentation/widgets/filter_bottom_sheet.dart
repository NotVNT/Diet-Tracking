import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';

/// Bottom sheet cho bộ lọc
class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApplyFilter;

  const FilterBottomSheet({
    super.key,
    this.onApplyFilter,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedCategory = 'all';
  RangeValues _calorieRange = const RangeValues(0, 1000);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(responsive.radius(20)),
        ),
      ),
      padding: EdgeInsets.all(responsive.width(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: responsive.width(40),
              height: responsive.height(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(responsive.radius(2)),
              ),
            ),
          ),
          SizedBox(height: responsive.height(20)),

          // Title
          Text(
            'Bộ lọc',
            style: TextStyle(
              fontSize: responsive.fontSize(20),
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: responsive.height(20)),

          // Category filter
          Text(
            'Danh mục',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: responsive.height(12)),
          Wrap(
            spacing: responsive.width(8),
            runSpacing: responsive.height(8),
            children: [
              _buildCategoryChip('all', 'Tất cả', responsive, theme),
              _buildCategoryChip('breakfast', 'Sáng', responsive, theme),
              _buildCategoryChip('lunch', 'Trưa', responsive, theme),
              _buildCategoryChip('dinner', 'Tối', responsive, theme),
              _buildCategoryChip('snack', 'Phụ', responsive, theme),
            ],
          ),
          SizedBox(height: responsive.height(20)),

          // Calorie range
          Text(
            'Khoảng calo: ${_calorieRange.start.round()} - ${_calorieRange.end.round()} kcal',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
          RangeSlider(
            values: _calorieRange,
            min: 0,
            max: 2000,
            divisions: 40,
            labels: RangeLabels(
              _calorieRange.start.round().toString(),
              _calorieRange.end.round().toString(),
            ),
            onChanged: (values) {
              setState(() {
                _calorieRange = values;
              });
            },
          ),
          SizedBox(height: responsive.height(20)),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = 'all';
                      _calorieRange = const RangeValues(0, 1000);
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.height(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.radius(12)),
                    ),
                  ),
                  child: Text(
                    'Đặt lại',
                    style: TextStyle(fontSize: responsive.fontSize(14)),
                  ),
                ),
              ),
              SizedBox(width: responsive.width(12)),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilter?.call({
                      'category': _selectedCategory,
                      'calorieMin': _calorieRange.start,
                      'calorieMax': _calorieRange.end,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: responsive.height(12),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.radius(12)),
                    ),
                  ),
                  child: Text(
                    'Áp dụng',
                    style: TextStyle(fontSize: responsive.fontSize(14)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.height(20)),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    String value,
    String label,
    ResponsiveHelper responsive,
    ThemeData theme,
  ) {
    final isSelected = _selectedCategory == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategory = value;
        });
      },
      borderRadius: BorderRadius.circular(responsive.radius(20)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.width(16),
          vertical: responsive.height(8),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(responsive.radius(20)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(13),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Helper function để hiển thị filter bottom sheet
void showFilterBottomSheet(
  BuildContext context, {
  Function(Map<String, dynamic>)? onApplyFilter,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FilterBottomSheet(
      onApplyFilter: onApplyFilter,
    ),
  );
}
