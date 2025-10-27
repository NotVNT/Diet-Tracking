import 'package:flutter/material.dart';
import '../../../../common/app_colors.dart';
import '../../../../common/app_styles.dart';

class CalorieFilter extends StatefulWidget {
  final Function(String?) onFilterChanged;

  const CalorieFilter({
    Key? key,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<CalorieFilter> createState() => _CalorieFilterState();
}

class _CalorieFilterState extends State<CalorieFilter> {
  String? selectedFilter;

  final List<Map<String, dynamic>> filterOptions = [
    {'label': '0-250 Cal', 'value': '0-250', 'min': 0, 'max': 250},
    {'label': '250-500 Cal', 'value': '250-500', 'min': 250, 'max': 500},
    {'label': '500-800 Cal', 'value': '500-800', 'min': 500, 'max': 800},
    {'label': '800-1200 Cal', 'value': '800-1200', 'min': 800, 'max': 1200},
    {'label': '1200-1600 Cal', 'value': '1200-1600', 'min': 1200, 'max': 1600},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterOptions.map((option) {
              final isSelected = selectedFilter == option['value'];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: isSelected,
                  label: Text(
                    option['label'],
                    style: AppStyles.bodyMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        selectedFilter = option['value'];
                      } else {
                        selectedFilter = null;
                      }
                    });
                    widget.onFilterChanged(selectedFilter);
                  },
                  backgroundColor: Colors.white,
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}