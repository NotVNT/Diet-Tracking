import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/nutrition_calculation_model.dart';

class NutritionInfoCard extends StatelessWidget {
  const NutritionInfoCard({
    super.key,
    required this.calculation,
  });

  final NutritionCalculation calculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.nutritionInfo,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),
          _InfoRow(
            label: AppLocalizations.of(context)!.bmr,
            value: AppLocalizations.of(context)!
                .calPerDay(calculation.bmr.toStringAsFixed(0)),
          ),
          _InfoRow(
            label: AppLocalizations.of(context)!.tdee,
            value: AppLocalizations.of(context)!
                .calPerDay(calculation.tdee.toStringAsFixed(0)),
          ),
          const Divider(height: 24),
          _InfoRow(
            label: AppLocalizations.of(context)!.targetCalories,
            value: AppLocalizations.of(context)!
                .calPerDay(calculation.targetCalories.toStringAsFixed(0)),
            isHighlight: true,
          ),
          _InfoRow(
            label: AppLocalizations.of(context)!.dailyAdjustment,
            value: AppLocalizations.of(context)!.calSuffix(
                calculation.dailyCaloriesAdjustment.toStringAsFixed(0)),
          ),
          const Divider(height: 24),
          _InfoRow(
            label: AppLocalizations.of(context)!.safeRange,
            value:
                '${calculation.caloriesMin.toStringAsFixed(0)} - ${AppLocalizations.of(context)!.calSuffix(calculation.caloriesMax.toStringAsFixed(0))}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
  });

  final String label;
  final String value;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isHighlight ? 16 : 14,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight
                  ? const Color(0xFF1F2A37)
                  : const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
