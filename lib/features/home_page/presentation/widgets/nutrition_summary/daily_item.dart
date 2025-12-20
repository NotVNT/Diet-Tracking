import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/nutrition_totals.dart';

class DailyItem extends StatelessWidget {
  final DateTime date;
  final NutritionTotals totals;

  const DailyItem({super.key, required this.date, required this.totals});

  @override
  Widget build(BuildContext context) {
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: Colors.blue.withAlpha(128), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          // Date Column
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(DateFormat('EEE', 'vi').format(date).toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        color: isToday ? Colors.white : Colors.grey)),
                Text(DateFormat('dd').format(date),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : Colors.black)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${totals.calories.toStringAsFixed(0)} kcal",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _nutrientText("P", totals.protein, Colors.purple),
                    const SizedBox(width: 12),
                    _nutrientText("C", totals.carbs, Colors.orange),
                    const SizedBox(width: 12),
                    _nutrientText("F", totals.fat, Colors.teal),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _nutrientText(String label, double value, Color color) {
    return Text("$label ${value.toStringAsFixed(0)}",
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600));
  }
}

