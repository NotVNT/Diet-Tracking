import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../components/meal_list_item.dart';

/// Widget hiển thị danh sách bữa ăn
class MealsListSection extends StatelessWidget {
  final List<FoodRecordEntity> meals;
  final Function(FoodRecordEntity)? onMealTap;
  final VoidCallback? onViewAll;

  const MealsListSection({
    super.key,
    required this.meals,
    this.onMealTap,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.width(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations?.mealsListTitle ?? 'Danh sách bữa ăn',
                style: TextStyle(
                  fontSize: responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (meals.length > 3 && onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    localizations?.viewAll ?? 'Xem tất cả',
                    style: TextStyle(
                      fontSize: responsive.fontSize(13),
                    ),
                  ),
                ),
            ],
          ),
        ),

        SizedBox(height: responsive.height(8)),

        // List
        if (meals.isEmpty)
          _buildEmptyState(context, responsive, localizations)
        else
          _buildMealsList(context, responsive),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, ResponsiveHelper responsive, AppLocalizations? localizations) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: responsive.width(16)),
      padding: EdgeInsets.all(responsive.width(24)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(responsive.width(12)),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.restaurant_menu,
            size: responsive.width(48),
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: responsive.height(12)),
          Text(
            localizations?.noMealsYet ?? 'Chưa có bữa ăn nào',
            style: TextStyle(
              fontSize: responsive.fontSize(14),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: responsive.height(4)),
          Text(
            localizations?.startByScanningOrPhoto ?? 'Quét barcode hoặc chụp ảnh món ăn để bắt đầu',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: responsive.fontSize(12),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, ResponsiveHelper responsive) {
    // Hiển thị tối đa 5 items
    final displayMeals = meals.take(5).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: responsive.width(16)),
      itemCount: displayMeals.length,
      separatorBuilder: (context, index) =>
          SizedBox(height: responsive.height(8)),
      itemBuilder: (context, index) {
        final meal = displayMeals[index];
        return MealListItem(
          food: meal,
          onTap: onMealTap != null ? () => onMealTap!(meal) : null,
        );
      },
    );
  }
}
