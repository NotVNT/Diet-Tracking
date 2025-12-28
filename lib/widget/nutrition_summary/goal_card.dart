import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import '../../../model/nutrition_calculation_model.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.userInfo,
    required this.targetDays,
  });

  final UserNutritionInfo userInfo;
  final int targetDays;

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
              Icon(
                userInfo.isLosingWeight
                    ? Icons.trending_down
                    : Icons.trending_up,
                color: const Color(0xFF1F2A37),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context)!.yourGoal,
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
            AppLocalizations.of(context)!.currentWeight,
            '${userInfo.currentWeightKg.toStringAsFixed(1)} kg',
          ),
          _buildInfoRow(
            AppLocalizations.of(context)!.targetWeight,
            '${userInfo.targetWeightKg.toStringAsFixed(1)} kg',
          ),
          _buildInfoRow(
            AppLocalizations.of(context)!.difference,
            '${userInfo.weightDifference.toStringAsFixed(1)} kg',
            isHighlight: true,
          ),
          _buildInfoRow(
            AppLocalizations.of(context)!.time,
            AppLocalizations.of(context)!.daysWeeks(
                targetDays, (targetDays / 7).toStringAsFixed(1)),
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
