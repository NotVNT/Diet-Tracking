import 'package:flutter/material.dart';

import '../../../domain/entities/nutrition_totals.dart';
import 'calories_bar_chart.dart';
import 'daily_item.dart';
import 'summary_cards.dart';

class ReportView extends StatelessWidget {
  final List<DateTime> days;
  final Map<DateTime, NutritionTotals> byDay;
  final NutritionTotals total;
  final String header;
  final bool isMonthly;

  const ReportView({
    super.key,
    required this.days,
    required this.byDay,
    required this.total,
    required this.header,
    required this.isMonthly,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              header,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SummaryCards(totals: total),
            const SizedBox(height: 24),
            Text(
              "Biểu đồ Calo",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: CaloriesBarChart(
                days: days,
                byDay: byDay,
                isMonthly: isMonthly,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Chi tiết theo ngày",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final d = days[days.length - 1 - index];
                final t =
                    byDay[DateTime(d.year, d.month, d.day)] ??
                    NutritionTotals();
                return DailyItem(date: d, totals: t);
              },
            ),
          ],
        ),
      ),
    );
  }
}
