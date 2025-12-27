import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';
import 'package:diet_tracking_project/widget/target_days/nutrition_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Material(
        child: Center(child: child),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('NutritionInfoCard', () {
    testWidgets('renders nutrition calculation values', (tester) async {
      final calculation = NutritionCalculation(
        bmr: 1500,
        tdee: 2000,
        caloriesMax: 1800,
        caloriesMin: 1200,
        weightDifference: 5,
        totalCaloriesNeeded: 35000,
        dailyCaloriesAdjustment: -500,
        targetCalories: 1500,
        targetDays: 70,
        isHealthy: true,
      );

      await tester.pumpWidget(_wrap(NutritionInfoCard(calculation: calculation)));

      expect(find.text('Thông tin dinh dưỡng'), findsOneWidget);

      expect(find.text('BMR'), findsOneWidget);
      // 1500 cal/ngày appears in multiple rows (e.g., BMR and target calories).
      expect(find.text('1500 cal/ngày'), findsNWidgets(2));

      expect(find.text('TDEE'), findsOneWidget);
      expect(find.text('2000 cal/ngày'), findsOneWidget);

      expect(find.text('Calories mục tiêu'), findsOneWidget);
      // Covered by the findsNWidgets assertion above.

      expect(find.text('Điều chỉnh mỗi ngày'), findsOneWidget);
      expect(find.text('-500 cal'), findsOneWidget);

      expect(find.text('Khoảng an toàn'), findsOneWidget);
      expect(find.text('1200 - 1800 cal'), findsOneWidget);
    });
  });
}
