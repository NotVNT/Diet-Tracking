import 'package:flutter/material.dart';

/// Centralized color and emoji config for nutrients.
/// Ensures consistency across the app and easy maintenance.
/// Supports both light and dark modes.
class NutrientColorScheme {
  // Primary nutrient colors - Light mode
  static const Color proteinLight = Color(0xFF3B82F6); // Blue
  static const Color carbsLight = Color(0xFFF59E0B);   // Orange/Amber
  static const Color fatLight = Color(0xFFFACC15);     // Yellow
  static const Color calorieLight = Color(0xFF6366F1); // Indigo

  // Primary nutrient colors - Dark mode
  static const Color proteinDark = Color(0xFF60A5FA);  // Lighter Blue
  static const Color carbsDark = Color(0xFFFFBF4D);    // Lighter Orange
  static const Color fatDark = Color(0xFFFDE047);      // Lighter Yellow
  static const Color calorieDark = Color(0xFFA78BFA);  // Lighter Purple

  // Backward compatibility - default to light mode colors
  static const Color protein = proteinLight;
  static const Color carbs = carbsLight;
  static const Color fat = fatLight;
  static const Color calorie = calorieLight;

  // Gradient for the calorie ring (smooth blue to purple) - Light mode
  static const List<Color> calorieRingGradientLight = <Color>[
    Color(0xFF22D3EE), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
  ];

  // Gradient for the calorie ring - Dark mode
  static const List<Color> calorieRingGradientDark = <Color>[
    Color(0xFF06B6D4), // Darker Cyan
    Color(0xFF60A5FA), // Lighter Blue
    Color(0xFFA78BFA), // Lighter Purple
    Color(0xFFD8B4FE), // Very Light Purple
  ];

  // Backward compatibility
  static const List<Color> calorieRingGradient = calorieRingGradientLight;

  /// Get emoji icon for nutrient type
  static String getEmoji(NutrientType type) {
    switch (type) {
      case NutrientType.protein:
        return '🥩';
      case NutrientType.carbs:
        return '🍚';
      case NutrientType.fat:
        return '🥑';
      case NutrientType.calorie:
        return '🔥';
    }
  }

  /// Get color for nutrient type based on brightness
  static Color getColor(NutrientType type, {required bool isDarkMode}) {
    switch (type) {
      case NutrientType.protein:
        return isDarkMode ? proteinDark : proteinLight;
      case NutrientType.carbs:
        return isDarkMode ? carbsDark : carbsLight;
      case NutrientType.fat:
        return isDarkMode ? fatDark : fatLight;
      case NutrientType.calorie:
        return isDarkMode ? calorieDark : calorieLight;
    }
  }

  /// Get gradient for calorie ring based on brightness
  static List<Color> getCalorieRingGradient({required bool isDarkMode}) {
    return isDarkMode ? calorieRingGradientDark : calorieRingGradientLight;
  }
}

/// Nutrient type enum
enum NutrientType { protein, carbs, fat, calorie }

