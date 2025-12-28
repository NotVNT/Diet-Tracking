import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../model/nutrition_calculation_model.dart';
import '../../../services/nutrition_calculator_service.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.userInfo,
  });

  final UserNutritionInfo userInfo;

  @override
  Widget build(BuildContext context) {
    final recommendedDays = NutritionCalculatorService.calculateRecommendedDays(
      userInfo: userInfo,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFF10B981),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.recommendation,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.recommendationDaysWeeks(
                recommendedDays, (recommendedDays / 7).toStringAsFixed(1)),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF065F46),
            ),
          ),
        ],
      ),
    );
  }
}
