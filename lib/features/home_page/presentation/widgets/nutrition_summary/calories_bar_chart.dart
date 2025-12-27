import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/nutrition_totals.dart';

class CaloriesBarChart extends StatelessWidget {
  final List<DateTime> days;
  final Map<DateTime, NutritionTotals> byDay;
  final bool isMonthly;

  const CaloriesBarChart({
    super.key,
    required this.days,
    required this.byDay,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onSurface = theme.colorScheme.onSurface;
    final onPrimary = theme.colorScheme.onPrimary;

    double maxY = 0;
    for (var t in byDay.values) {
      if (t.calories > maxY) maxY = t.calories;
    }
    if (maxY == 0) maxY = 2000; // Default max Y value

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY * 1.2, // Add some padding to the top
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => primary,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}\nkcal',
                TextStyle(color: onPrimary, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  // For monthly view, show fewer labels to avoid clutter
                  if (isMonthly && value.toInt() % 5 != 0) {
                    return const SizedBox.shrink();
                  }

                  final d = days[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd').format(d),
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.6),
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: days.asMap().entries.map((entry) {
          final index = entry.key;
          final d = entry.value;
          final t =
              byDay[DateTime(d.year, d.month, d.day)] ?? NutritionTotals();

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: t.calories,
                color: t.calories == 0
                    ? onSurface.withValues(alpha: 0.2)
                    : primary,
                width: isMonthly ? 6 : 12,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY * 1.2,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
