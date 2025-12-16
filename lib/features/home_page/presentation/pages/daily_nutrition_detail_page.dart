import 'package:flutter/material.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../widgets/cards/calorie_goal_card.dart'; // Reusing the existing model

/// A page that displays detailed nutrition information for a specific day.
class DailyNutritionDetailPage extends StatelessWidget {
  final DateTime date;
  final List<FoodRecordEntity> foodRecords;

  const DailyNutritionDetailPage({
    super.key,
    required this.date,
    required this.foodRecords,
  });

  @override
  Widget build(BuildContext context) {
    final nutritionInfo = NutritionInfo.fromRecordsForDate(
      records: foodRecords,
      date: date,
      calorieGoal: 2273, // TODO: Replace with dynamic goal
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết dinh dưỡng'), // TODO: Add localization
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSummaryHeader(context, nutritionInfo),
          const SizedBox(height: 24),
          _buildFoodList(context),
        ],
      ),
    );
  }

  /// Builds the summary card at the top.
  Widget _buildSummaryHeader(BuildContext context, NutritionInfo nutritionInfo) {
    return CalorieGoalCard(
      nutritionInfo: nutritionInfo,
      // No navigation from the detail page itself
      onViewReport: null,
    );
  }

  /// Builds the list of food items for the day.
  Widget _buildFoodList(BuildContext context) {
    if (foodRecords.isEmpty) {
      return const Center(
        child: Text('Chưa có dữ liệu cho ngày này.'), // TODO: Localization
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Các món đã ăn', // TODO: Localization
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...foodRecords.map((record) => _buildFoodItem(context, record)).toList(),
      ],
    );
  }

  /// Builds a single food item card.
  Widget _buildFoodItem(BuildContext context, FoodRecordEntity record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        // TODO: Add leading image if available
        title: Text(record.foodName),
        subtitle: Text('${record.calories.round()} kcal'), // TODO: Localization
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to the specific food record detail if needed
        },
      ),
    );
  }
}

