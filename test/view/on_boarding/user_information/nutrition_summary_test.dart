import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:diet_tracking_project/view/on_boarding/user_information/nutrition_summary.dart';

Widget _buildApp(Widget home) {
  return MaterialApp(home: home);
}

Map<String, dynamic> _validCalculationJson({
  int targetDays = 30,
  bool isHealthy = true,
}) {
  return {
    'bmr': 1600.0,
    'tdee': 2000.0,
    'caloriesMax': 3000.0,
    'caloriesMin': 1500.0,
    'weightDifference': 5.0,
    'totalCaloriesNeeded': 38500.0,
    'dailyCaloriesAdjustment': 1283.33,
    'targetCalories': 1800.0,
    'targetDays': targetDays,
    'isHealthy': isHealthy,
    'warningMessage': isHealthy ? null : 'Test warning',
  };
}

void main() {
  testWidgets('NutritionSummary: shows main content when data exists', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    SharedPreferences.setMockInitialValues({
      'guest_age': 30,
      'guest_gender': 'Male',
      'guest_height_cm': 175.0,
      'guest_weight_kg': 80.0,
      'guest_goal_weight_kg': 75.0,
      'guest_activity_level': 'Ít vận động',
      'targetDays': 30,
      'nutritionCalculation': jsonEncode(_validCalculationJson(targetDays: 30)),
    });

    await tester.pumpWidget(_buildApp(const NutritionSummary()));

    // Loading first.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Tổng kết kế hoạch'), findsOneWidget);
    expect(find.text('Calories mục tiêu'), findsOneWidget);
  });

  testWidgets('NutritionSummary: shows error view when data is missing', (tester) async {
    SharedPreferences.setMockInitialValues({
      // Even if guest data exists, missing targetDays/nutritionCalculation triggers error view.
      'guest_age': 30,
      'guest_gender': 'Male',
      'guest_height_cm': 175.0,
      'guest_weight_kg': 80.0,
      'guest_goal_weight_kg': 75.0,
      'guest_activity_level': 'Ít vận động',
    });

    await tester.pumpWidget(_buildApp(const NutritionSummary()));
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy dữ liệu tính toán.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Quay lại'), findsOneWidget);
  });
}
