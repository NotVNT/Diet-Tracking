import 'package:flutter/material.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

/// Utility class for BMI calculations and descriptions
class BmiCalculator {
  /// Computes BMI from weight in kg and height in cm
  static double computeBmi(double weightKg, double? heightCm) {
    if (heightCm == null || heightCm <= 0) return 0;
    final h = heightCm / 100.0;
    return weightKg / (h * h);
  }

  /// Returns a localized description of the BMI category
  static String bmiDescription(BuildContext context, double bmi) {
        final l10n = AppLocalizations.of(context)!;
    if (bmi == 0) {
      return l10n.bmiEnterHeightToCalculate;
    }
    if (bmi < 18.5) {
      return l10n.bmiUnderweight;
    }
    if (bmi < 25) {
      return l10n.bmiNormal;
    }
    if (bmi < 30) {
      return l10n.bmiOverweight;
    }
    return l10n.bmiObese;
  }
}
