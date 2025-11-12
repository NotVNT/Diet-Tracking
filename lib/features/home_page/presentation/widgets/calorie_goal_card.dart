import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';
import '../../../../l10n/app_localizations.dart';

/// Model cho thông tin dinh dưỡng
class NutritionInfo {
  final double calorieGoal;
  final double calorieConsumed;
  final double calorieRemaining;
  final double proteinConsumed;
  final double carbsConsumed;

  NutritionInfo({
    required this.calorieGoal,
    required this.calorieConsumed,
    this.proteinConsumed = 0,
    this.carbsConsumed = 0,
  }) : calorieRemaining = calorieGoal - calorieConsumed;

  double get progress => calorieConsumed / calorieGoal;
}

/// Widget hiển thị mục tiêu calo với circular progress
class CalorieGoalCard extends StatelessWidget {
  final NutritionInfo nutritionInfo;
  final VoidCallback? onViewReport;

  const CalorieGoalCard({
    super.key,
    required this.nutritionInfo,
    this.onViewReport,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(responsive.width(20)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and view report button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations?.calorieGoalTitle ?? 'Mục tiêu calo',
                style: TextStyle(
                  fontSize: responsive.fontSize(18),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onViewReport,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.width(12),
                    vertical: responsive.height(6),
                  ),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(8)),
                  ),
                ),
                child: Text(
                  localizations?.viewReport ?? 'Xem báo cáo',
                  style: TextStyle(
                    fontSize: responsive.fontSize(13),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.height(24)),

          // Circular progress indicator
          Center(
            child: SizedBox(
              width: responsive.width(180),
              height: responsive.width(180),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background circle
                  SizedBox(
                    width: responsive.width(180),
                    height: responsive.width(180),
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: responsive.width(12),
                      backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    ),
                  ),
                  // Progress circle
                  SizedBox(
                    width: responsive.width(180),
                    height: responsive.width(180),
                    child: CircularProgressIndicator(
                      value: nutritionInfo.progress.clamp(0.0, 1.0),
                      strokeWidth: responsive.width(12),
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  // Center text
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nutritionInfo.calorieRemaining.round().toString(),
                        style: TextStyle(
                          fontSize: responsive.fontSize(40),
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        localizations?.calorieRemaining ?? 'Calo còn lại',
                        style: TextStyle(
                          fontSize: responsive.fontSize(14),
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: responsive.height(24)),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.flag_outlined,
                label: localizations?.goalLabel ?? 'Mục tiêu',
                value: _formatNumber(nutritionInfo.calorieGoal),
                responsive: responsive,
                theme: theme,
              ),
              _buildStatItem(
                context,
                icon: Icons.restaurant_outlined,
                label: localizations?.consumedLabel ?? 'Đã nạp',
                value: _formatNumber(nutritionInfo.calorieConsumed),
                responsive: responsive,
                theme: theme,
              ),
              _buildStatItem(
                context,
                icon: Icons.local_fire_department_outlined,
                label: localizations?.exerciseLabel ?? 'Tập luyện',
                value: '0', // TODO: Add exercise calories
                responsive: responsive,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ResponsiveHelper responsive,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: responsive.iconSize(24),
          color: theme.colorScheme.primary,
        ),
        SizedBox(height: responsive.height(8)),
        Text(
          value,
          style: TextStyle(
            fontSize: responsive.fontSize(18),
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: responsive.height(4)),
        Text(
          label,
          style: TextStyle(
            fontSize: responsive.fontSize(12),
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  String _formatNumber(double number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
    }
    return number.round().toString();
  }
}
