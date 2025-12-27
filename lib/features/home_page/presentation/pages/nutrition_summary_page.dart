import 'package:flutter/material.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../widgets/nutrition_summary/monthly_report.dart';
import '../widgets/nutrition_summary/weekly_report.dart';

class NutritionSummaryPage extends StatelessWidget {
  final DateTime selectedDate;
  final List<FoodRecordEntity> allRecords;

  const NutritionSummaryPage({
    super.key,
    required this.selectedDate,
    required this.allRecords,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerHighest,
        appBar: AppBar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Text(
            'Thống kê dinh dưỡng',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: TabBar(
            labelColor: primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
            indicatorColor: primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'Tuần này'),
              Tab(text: 'Tháng này'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WeeklyReport(selectedDate: selectedDate, allRecords: allRecords),
            MonthlyReport(selectedDate: selectedDate, allRecords: allRecords),
          ],
        ),
      ),
    );
  }
}
