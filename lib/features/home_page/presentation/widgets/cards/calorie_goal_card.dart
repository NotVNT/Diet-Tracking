import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';
import '../components/calorie_ring.dart';
import '../components/nutrient_item.dart';
import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../components/nutrient_color_scheme.dart';

class NutritionInfo {
  final double calorieGoal;
  final double calorieConsumed;
  final double proteinConsumed;
  final double carbsConsumed;
  final double fatConsumed;

  // Optional goals for nutrient bars
  final double proteinGoal;
  final double carbsGoal;
  final double fatGoal;

  NutritionInfo({
    required this.calorieGoal,
    required this.calorieConsumed,
    this.proteinConsumed = 0,
    this.carbsConsumed = 0,
    this.fatConsumed = 0,
    this.proteinGoal = 25,
    this.carbsGoal = 50,
    this.fatGoal = 70, // Default fat goal
  });

  factory NutritionInfo.fromRecordsForDate({
    required List<FoodRecordEntity> records,
    required DateTime date,
    required double calorieGoal,
    double proteinGoal = 25,
    double carbsGoal = 50,
    double fatGoal = 70,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));

    double cal = 0, pro = 0, carbs = 0, fat = 0;

    for (final r in records) {
      final d = r.date.toLocal();
      if (!d.isBefore(start) && d.isBefore(end)) {
        cal += r.calories;
        pro += (r.protein ?? 0);
        carbs += (r.carbs ?? 0);
        fat += (r.fat ?? 0);
      }
    }

    return NutritionInfo(
      calorieGoal: calorieGoal,
      calorieConsumed: cal,
      proteinConsumed: pro,
      carbsConsumed: carbs,
      fatConsumed: fat,
      proteinGoal: proteinGoal,
      carbsGoal: carbsGoal,
      fatGoal: fatGoal,
    );
  }

  bool get hasAnyCalories => calorieConsumed > 0;


  double get progress =>
      calorieGoal == 0 ? 0 : (calorieConsumed / calorieGoal).clamp(0, 1);
}

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
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    // Use Material with elevation for optimized rendering
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(responsive.radius(16)),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(responsive.width(16)),
        child: Column(
          children: [
            // Top row: circular summary + nutrient bars
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: CalorieRing(
                    progress: nutritionInfo.progress,
                    size: responsive.width(160),
                    trackWidth: responsive.width(12),
                    color: NutrientColorScheme.getColor(
                      NutrientType.calorie,
                      isDarkMode: isDarkMode,
                    ),
                    gradientColors: NutrientColorScheme.getCalorieRingGradient(
                      isDarkMode: isDarkMode,
                    ),
                    centerNumber: nutritionInfo.calorieConsumed.round().toString(),
                    centerSubtitle: (l10n?.calorieCardBurnedToday ?? 'Your calories burned today'),
                    enableGlowEffect: true,
                    showHeadDot: !nutritionInfo.hasAnyCalories,
                  ),
                ),
                SizedBox(width: responsive.width(16)),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      NutrientItem(
                        title: (l10n?.nutrientProtein ?? 'Protein'),
                        valueText:
                            '${nutritionInfo.proteinConsumed.round()}/${nutritionInfo.proteinGoal.round()}g',
                        progress: nutritionInfo.proteinGoal == 0
                            ? 0
                            : (nutritionInfo.proteinConsumed /
                                    nutritionInfo.proteinGoal)
                                .clamp(0, 1),
                        color: NutrientColorScheme.getColor(
                          NutrientType.protein,
                          isDarkMode: isDarkMode,
                        ),
                        icon: NutrientColorScheme.getEmoji(NutrientType.protein),
                      ),
                      SizedBox(height: responsive.height(8)),
                      NutrientItem(
                        title: (l10n?.nutrientCarbs ?? 'Carbs'),
                        valueText:
                            '${nutritionInfo.carbsConsumed.round()}/${nutritionInfo.carbsGoal.round()}g',
                        progress: nutritionInfo.carbsGoal == 0
                            ? 0
                            : (nutritionInfo.carbsConsumed /
                                    nutritionInfo.carbsGoal)
                                .clamp(0, 1),
                        color: NutrientColorScheme.getColor(
                          NutrientType.carbs,
                          isDarkMode: isDarkMode,
                        ),
                        icon: NutrientColorScheme.getEmoji(NutrientType.carbs),
                      ),
                      SizedBox(height: responsive.height(8)),
                      NutrientItem(
                        title: (l10n?.nutrientFat ?? 'Fat'),
                        valueText:
                            '${nutritionInfo.fatConsumed.round()}/${nutritionInfo.fatGoal.round()}g',
                        progress: nutritionInfo.fatGoal == 0
                            ? 0
                            : (nutritionInfo.fatConsumed /
                                    nutritionInfo.fatGoal)
                                .clamp(0, 1),
                        color: NutrientColorScheme.getColor(
                          NutrientType.fat,
                          isDarkMode: isDarkMode,
                        ),
                        icon: NutrientColorScheme.getEmoji(NutrientType.fat),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.height(16)),

            // Bottom row: calories taken + optional report action
            Row(
              children: [
                Text(
                  '🔥',
                  style: TextStyle(fontSize: responsive.fontSize(18)),
                ),
                SizedBox(width: responsive.width(8)),
                Expanded(
                  child: Text(
                    '${nutritionInfo.calorieConsumed.round()} ${l10n?.calorieCardCaloriesTaken ?? 'Calories taken'}',
                    style: TextStyle(
                      fontSize: responsive.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (onViewReport != null)
                  IconButton(
                    tooltip: (l10n?.calorieCardViewReport ?? 'View report'),
                    onPressed: onViewReport,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: responsive.iconSize(16),
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



