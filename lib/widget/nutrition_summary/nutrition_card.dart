import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../model/nutrition_calculation_model.dart';

class NutritionCard extends StatelessWidget {
  const NutritionCard({
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
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu,
                color: Color(0xFF1F2A37),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.nutritionInfo,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'BMR',
            AppLocalizations.of(context)!
                .calPerDay(calculation.bmr.toStringAsFixed(0)),
          ),
          _buildInfoRow(
            'TDEE',
            AppLocalizations.of(context)!
                .calPerDay(calculation.tdee.toStringAsFixed(0)),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            AppLocalizations.of(context)!.targetCalories,
            AppLocalizations.of(context)!
                .calPerDay(calculation.targetCalories.toStringAsFixed(0)),
            isHighlight: true,
          ),
          _buildInfoRow(
            AppLocalizations.of(context)!.safeRange,
            AppLocalizations.of(context)!.calSuffix(
                '${calculation.caloriesMin.toStringAsFixed(0)} - ${calculation.caloriesMax.toStringAsFixed(0)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
