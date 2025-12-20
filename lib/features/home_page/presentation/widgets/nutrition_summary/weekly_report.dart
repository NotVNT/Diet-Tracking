import 'package:flutter/material.dart';

import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../domain/entities/nutrition_totals.dart';
import 'report_view.dart';

class WeeklyReport extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const WeeklyReport({super.key, required this.selectedDate, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    final start = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
    final days = List<DateTime>.generate(7, (i) => start.add(Duration(days: i)));
    
    final byDay = <DateTime, NutritionTotals>{for (final d in days) DateTime(d.year, d.month, d.day): NutritionTotals()};
    for (final r in allRecords) {
      final d = DateTime(r.date.year, r.date.month, r.date.day);
      if (byDay.containsKey(d)) {
        final t = byDay[d]!;
        t.calories += r.calories;
        t.protein += r.protein ?? 0;
        t.carbs += r.carbs ?? 0;
        t.fat += r.fat ?? 0;
      }
    }
    final total = byDay.values.fold<NutritionTotals>(NutritionTotals(), (acc, v) => acc + v);

    return ReportView(
      days: days, 
      byDay: byDay, 
      total: total, 
      header: 'Tổng kết tuần',
      isMonthly: false,
    );
  }
}

