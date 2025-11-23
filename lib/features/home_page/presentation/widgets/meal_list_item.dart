import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';

/// Widget để hiển thị một món ăn trong danh sách
class MealListItem extends StatelessWidget {
  final FoodRecordEntity food;
  final VoidCallback? onTap;

  const MealListItem({super.key, required this.food, this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(responsive.width(12)),
      child: Container(
        padding: EdgeInsets.all(responsive.width(12)),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(responsive.width(12)),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon chỉ hiển thị cho food, không hiển thị cho barcode
            if (food.recordType != RecordType.barcode) ...[
              _buildIcon(context, responsive),
              SizedBox(width: responsive.width(12)),
            ],

            // Thông tin món ăn
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món ăn
                  Text(
                    food.foodName.isNotEmpty ? food.foodName : 'No Food Detected',
                    style: TextStyle(
                      fontSize: responsive.fontSize(13),
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: responsive.height(6)),

                  // Calories với icon lửa
                  Row(
                    children: [
                      Text(
                        '🔥 ${food.calories.toStringAsFixed(0)} kcal',
                        style: TextStyle(
                          fontSize: responsive.fontSize(12),
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: responsive.height(4)),

                  // Nutrition info từ description
                  _buildNutritionInfo(context, responsive),

                  // Thời gian
                  SizedBox(height: responsive.height(6)),
                  Text(
                    _formatTime(food.date),
                    style: TextStyle(
                      fontSize: responsive.fontSize(10),
                      color: theme.colorScheme.primary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              size: responsive.width(20),
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ResponsiveHelper responsive) {
    final theme = Theme.of(context);

    IconData iconData;
    Color iconColor;

    switch (food.recordType) {
      case RecordType.barcode:
        iconData = Icons.qr_code_scanner;
        iconColor = theme.colorScheme.primary;
        break;
      case RecordType.food:
        iconData = Icons.restaurant;
        iconColor = Colors.green;
        break;
      default:
        iconData = Icons.fastfood;
        iconColor = Colors.orange;
        break;
    }

    return Container(
      width: responsive.width(44),
      height: responsive.width(44),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(responsive.width(10)),
      ),
      child: Icon(iconData, size: responsive.width(24), color: iconColor),
    );
  }

  /// Parse nutrition info từ description và hiển thị dạng icon + giá trị
  Widget _buildNutritionInfo(
    BuildContext context,
    ResponsiveHelper responsive,
  ) {
    if (food.nutritionDetails == null || food.nutritionDetails!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final description = food.nutritionDetails!;

    // Parse các giá trị dinh dưỡng từ description
    final proteinMatch = RegExp(
      r'Protein:\s*([0-9.]+)g',
    ).firstMatch(description);
    final carbsMatch = RegExp(r'Carbs:\s*([0-9.]+)g').firstMatch(description);
    final fatMatch = RegExp(r'Fat:\s*([0-9.]+)g').firstMatch(description);

    final protein = proteinMatch != null ? proteinMatch.group(1) : null;
    final carbs = carbsMatch != null ? carbsMatch.group(1) : null;
    final fat = fatMatch != null ? fatMatch.group(1) : null;

    // Nếu không có thông tin dinh dưỡng, không hiển thị gì
    if (protein == null && carbs == null && fat == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: responsive.width(12),
      runSpacing: responsive.height(4),
      children: [
        if (protein != null)
          Text(
            '� ${protein}g',
            style: TextStyle(
              fontSize: responsive.fontSize(11),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        if (carbs != null)
          Text(
            '🍚 ${carbs}g',
            style: TextStyle(
              fontSize: responsive.fontSize(11),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        if (fat != null)
          Text(
            '🧈 ${fat}g',
            style: TextStyle(
              fontSize: responsive.fontSize(11),
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
      ],
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
