import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../model/nutrition_calculation_model.dart';

class WarningCard extends StatelessWidget {
  const WarningCard({
    super.key,
    required this.calculation,
  });

  final NutritionCalculation calculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFEF4444),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                '⚠️ ${AppLocalizations.of(context)!.warning}',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            calculation.warningMessage ?? '',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF991B1B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
