import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../domain/entities/nutrition_totals.dart';
import 'report_view.dart';

class MonthlyReport extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const MonthlyReport({super.key, required this.selectedDate, required this.allRecords});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDay = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    final days = List<DateTime>.generate(lastDay.day, (i) => DateTime(first.year, first.month, i + 1));

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
      header: 'Tổng kết tháng ${DateFormat('MM/yyyy').format(selectedDate)}',
      isMonthly: true,
    );
  }
}

