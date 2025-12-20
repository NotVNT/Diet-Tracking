import 'package:flutter/material.dart';

import '../../../domain/entities/nutrition_totals.dart';

class SummaryCards extends StatelessWidget {
  final NutritionTotals totals;

  const SummaryCards({super.key, required this.totals});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _infoCard("Calories", "${totals.calories.toStringAsFixed(0)}", "kcal", Colors.blue)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              _miniInfoCard("Protein", "${totals.protein.toStringAsFixed(0)}g", Colors.purple),
              const SizedBox(height: 8),
              _miniInfoCard("Carbs", "${totals.carbs.toStringAsFixed(0)}g", Colors.orange),
              const SizedBox(height: 8),
              _miniInfoCard("Fat", "${totals.fat.toStringAsFixed(0)}g", Colors.teal),
            ],
          ),
        )
      ],
    );
  }

  Widget _infoCard(String label, String value, String unit, Color color) {
    return Container(
      height: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_fire_department_rounded, color: color, size: 32),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text("$unit • $label", style: TextStyle(color: color.withAlpha(204), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _miniInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 4, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

