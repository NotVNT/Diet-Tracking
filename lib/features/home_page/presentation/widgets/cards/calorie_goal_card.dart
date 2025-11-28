import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import '../../../../../l10n/app_localizations.dart';

/// Nutrition summary used by CalorieGoalCard
class NutritionInfo {
  final double calorieGoal;
  final double calorieConsumed;
  final double proteinConsumed;
  final double carbsConsumed;
  final double fiberConsumed;

  // Optional goals for nutrient bars
  final double proteinGoal;
  final double carbsGoal;
  final double fiberGoal;

  NutritionInfo({
    required this.calorieGoal,
    required this.calorieConsumed,
    this.proteinConsumed = 0,
    this.carbsConsumed = 0,
    this.fiberConsumed = 0,
    this.proteinGoal = 25,
    this.carbsGoal = 50,
    this.fiberGoal = 120,
  });

  double get progress =>
      calorieGoal == 0 ? 0 : (calorieConsumed / calorieGoal).clamp(0, 1);
}

/// Calorie goal card – refactored to match provided design without
/// changing external API (class name and constructor kept as-is).
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
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(responsive.width(16)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: circular summary + nutrient bars
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: _CalorieRing(
                  progress: nutritionInfo.progress,
                  size: responsive.width(160),
                  trackWidth: responsive.width(12),
                  color: theme.colorScheme.primary,
                  centerNumber: nutritionInfo.calorieConsumed.round().toString(),
                  centerSubtitle: (l10n?.calorieCardBurnedToday ?? 'Your calories burned today'),
                ),
              ),
              SizedBox(width: responsive.width(16)),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NutrientItem(
                      title: (l10n?.nutrientProtein ?? 'Protein'),
                      valueText:
                          '${nutritionInfo.proteinConsumed.round()}/${nutritionInfo.proteinGoal.round()}g',
                      progress: nutritionInfo.proteinGoal == 0
                          ? 0
                          : (nutritionInfo.proteinConsumed /
                                  nutritionInfo.proteinGoal)
                              .clamp(0, 1),
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(height: responsive.height(8)),
                    _NutrientItem(
                      title: (l10n?.nutrientFiber ?? 'Fiber'),
                      valueText:
                          '${nutritionInfo.fiberConsumed.round()}/${nutritionInfo.fiberGoal.round()}g',
                      progress: nutritionInfo.fiberGoal == 0
                          ? 0
                          : (nutritionInfo.fiberConsumed /
                                  nutritionInfo.fiberGoal)
                              .clamp(0, 1),
                      color: theme.colorScheme.tertiary,
                    ),
                    SizedBox(height: responsive.height(8)),
                    _NutrientItem(
                      title: (l10n?.nutrientCarbs ?? 'Carbs'),
                      valueText:
                          '${nutritionInfo.carbsConsumed.round()}/${nutritionInfo.carbsGoal.round()}g',
                      progress: nutritionInfo.carbsGoal == 0
                          ? 0
                          : (nutritionInfo.carbsConsumed /
                                  nutritionInfo.carbsGoal)
                              .clamp(0, 1),
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.height(16)),

          // Bottom row: calories taken + optional report action (kept for feature parity)
          Row(
            children: [
              Icon(Icons.restaurant, color: Colors.green.shade700,
                  size: responsive.iconSize(18)),
              SizedBox(width: responsive.width(8)),
              Expanded(
                child: Text(
                  '${nutritionInfo.calorieConsumed.round()} ' + (l10n?.calorieCardCaloriesTaken ?? 'Calories taken'),
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
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.progress,
    required this.size,
    required this.trackWidth,
    required this.color,
    required this.centerNumber,
    required this.centerSubtitle,
  });

  final double progress;
  final double size;
  final double trackWidth;
  final Color color;
  final String centerNumber;
  final String centerSubtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress,
              color: color,
              trackWidth: trackWidth,
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          ),
          // Center texts
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerNumber,
                style: TextStyle(
                  fontSize: size * 0.25,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: size * 0.02),
              Text(
                centerSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size * 0.085,
                  fontWeight: FontWeight.w400,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          // Head dot at end of arc
          _RingHeadDot(
            size: size,
            trackWidth: trackWidth,
            progress: progress,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackWidth,
    required this.backgroundColor,
  });

  final double progress;
  final Color color;
  final double trackWidth;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - trackWidth) / 2;
    final startAngle = -math.pi / 2; // start from top

    final trackPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round;

    // Draw background circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0,
      math.pi * 2,
      false,
      trackPaint,
    );

    // Draw progress
    final sweep = (math.pi * 2) * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackWidth != trackWidth ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

class _RingHeadDot extends StatelessWidget {
  const _RingHeadDot({
    required this.size,
    required this.trackWidth,
    required this.progress,
    required this.color,
  });

  final double size;
  final double trackWidth;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final angle = -math.pi / 2 + (math.pi * 2) * progress;
    final radius = (size - trackWidth) / 2;
    final center = Offset(size / 2, size / 2);
    final dotOffset = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );

    return Positioned(
      left: dotOffset.dx - trackWidth / 2,
      top: dotOffset.dy - trackWidth / 2,
      child: Container(
        width: trackWidth,
        height: trackWidth,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 6,
            )
          ],
        ),
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  const _NutrientItem({
    required this.title,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  final String title;
  final String valueText;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
