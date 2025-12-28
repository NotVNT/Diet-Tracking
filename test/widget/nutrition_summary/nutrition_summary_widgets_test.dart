import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';
import 'package:diet_tracking_project/widget/nutrition_summary/goal_card.dart';
import 'package:diet_tracking_project/widget/nutrition_summary/nutrition_card.dart';
import 'package:diet_tracking_project/widget/nutrition_summary/recommendation_card.dart';
import 'package:diet_tracking_project/widget/nutrition_summary/warning_card.dart';
import 'package:flutter/material.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget createWidgetUnderTest(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en'),
      Locale('vi'),
    ],
    locale: const Locale('en'), // Test in English
    home: Scaffold(
      body: child,
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final userInfo = UserNutritionInfo(
    age: 25,
    gender: 'Male',
    heightCm: 175,
    currentWeightKg: 80,
    targetWeightKg: 75,
    activityLevel: 'Moderate',
  );

  final calculation = NutritionCalculation(
    bmr: 1800,
    tdee: 2500,
    targetCalories: 2000,
    caloriesMin: 1800,
    caloriesMax: 2200,
    weightDifference: 5,
    totalCaloriesNeeded: 35000,
    dailyCaloriesAdjustment: -500,
    targetDays: 70,
    isHealthy: true,
  );

  group('Nutrition Summary Widgets', () {
    testWidgets('GoalCard renders correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        GoalCard(userInfo: userInfo, targetDays: 70),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Your Goal'), findsOneWidget);
      expect(find.text('Current Weight'), findsOneWidget);
      expect(find.text('80.0 kg'), findsOneWidget);
      expect(find.text('Target Weight'), findsOneWidget);
      expect(find.text('75.0 kg'), findsOneWidget);
      expect(find.text('Difference'), findsOneWidget);
      expect(find.text('5.0 kg'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('70 days (≈ 10.0 weeks)'), findsOneWidget);
    });

    testWidgets('NutritionCard renders correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        NutritionCard(calculation: calculation),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Nutrition Information'), findsOneWidget);
      expect(find.text('BMR'), findsOneWidget);
      expect(find.text('1800 cal/day'), findsOneWidget);
      expect(find.text('TDEE'), findsOneWidget);
      expect(find.text('2500 cal/day'), findsOneWidget);
      expect(find.text('Target Calories'), findsOneWidget);
      expect(find.text('2000 cal/day'), findsOneWidget);
      expect(find.text('Safe Range'), findsOneWidget);
      expect(find.text('1800 - 2200 cal'), findsOneWidget);
    });

    testWidgets('WarningCard renders correctly', (tester) async {
      final warningCalculation = NutritionCalculation(
        bmr: 1800,
        tdee: 2500,
        targetCalories: 1000, // Very low
        caloriesMin: 1800,
        caloriesMax: 2200,
        weightDifference: 5,
        totalCaloriesNeeded: 35000,
        dailyCaloriesAdjustment: -1500,
        targetDays: 23,
        isHealthy: false,
        warningMessage: 'Warning message test',
      );

      await tester.pumpWidget(createWidgetUnderTest(
        WarningCard(calculation: warningCalculation),
      ));
      await tester.pumpAndSettle();

      expect(find.text('⚠️ Warning'), findsOneWidget);
      expect(find.text('Warning message test'), findsOneWidget);
    });

    testWidgets('RecommendationCard renders correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        RecommendationCard(userInfo: userInfo),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Recommendation'), findsOneWidget);
      expect(find.textContaining('Recommendation:'), findsOneWidget);
    });
  });
}