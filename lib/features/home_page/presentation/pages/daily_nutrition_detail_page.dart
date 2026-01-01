import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../record_view_home/domain/entities/food_record_entity.dart';
import '../../../record_view_home/presentation/widgets/record_details_sheet.dart';
import '../widgets/cards/calorie_goal_card.dart'; // Reusing the existing model
import '../../../../utils/bottom_sheet_utils.dart';

/// A page that displays detailed nutrition information for a specific day.
class DailyNutritionDetailPage extends StatefulWidget {
  final DateTime date;
  final List<FoodRecordEntity> foodRecords;

  const DailyNutritionDetailPage({
    super.key,
    required this.date,
    required this.foodRecords,
  });

  @override
  State<DailyNutritionDetailPage> createState() =>
      _DailyNutritionDetailPageState();
}

class _DailyNutritionDetailPageState extends State<DailyNutritionDetailPage> {
  double? _targetCalories;

  @override
  void initState() {
    super.initState();
    _loadTargetCalories();
  }

  Future<void> _loadTargetCalories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('nutrition_plans')
          .doc('active_plan')
          .get(const GetOptions(source: Source.server));
      final data = doc.data();
      if (data != null && data['targetCalories'] != null) {
        setState(() {
          _targetCalories = (data['targetCalories'] as num).toDouble();
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print('Failed to load targetCalories: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final nutritionInfo = NutritionInfo.fromRecordsForDate(
      records: widget.foodRecords,
      date: widget.date,
      calorieGoal: _targetCalories ?? 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết dinh dưỡng'), // TODO: Add localization
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
  Widget _buildSummaryHeader(
    BuildContext context,
    NutritionInfo nutritionInfo,
  ) {
    return CalorieGoalCard(
      nutritionInfo: nutritionInfo,
      // No navigation from the detail page itself
      onViewReport: null,
    );
  }

  /// Builds the list of food items for the day.
  Widget _buildFoodList(BuildContext context) {
    if (widget.foodRecords.isEmpty) {
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
        ...widget.foodRecords
            .map((record) => _buildFoodItem(context, record))
            ,
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
        onTap: () {
          showCustomBottomSheet(
            context: context,
            builder: (context) => RecordDetailsSheet(record: record),
          );
        },
      ),
    );
  }
}
