import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weight_responsive_design.dart';

class BmiCard extends StatelessWidget {
  final double bmi;
  final String description;
  const BmiCard({super.key, required this.bmi, required this.description});

  Color _getBmiColor(double bmi) {
    if (bmi <= 0) return const Color(0xFF6B7280); // Grey
    if (bmi < 18.5) return const Color(0xFF3B82F6); // Blue (Underweight)
    if (bmi < 25) return const Color(0xFF10B981); // Green (Normal)
    if (bmi < 30) return const Color(0xFFF59E0B); // Orange (Overweight)
    return const Color(0xFFEF4444); // Red (Obese)
  }

  @override
  Widget build(BuildContext context) {
    final r = WeightResponsive.of(context);
    final statusColor = _getBmiColor(bmi);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.space(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(12)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.space(12),
              vertical: r.space(8),
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.radius(8)),
            ),
            child: Text(
              bmi == 0 ? '--' : bmi.toStringAsFixed(1),
              style: GoogleFonts.inter(
                fontSize: r.font(24),
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
          SizedBox(width: r.space(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      'BMI',
                      style: GoogleFonts.inter(
                        fontSize: r.font(12),
                        fontWeight: FontWeight.w800,
                        color: statusColor,
                      ),
                    ),
                    SizedBox(width: r.space(4)),
                    Icon(
                      Icons.info_outline,
                      size: r.font(14),
                      color: statusColor.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                SizedBox(height: r.space(4)),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: r.font(13),
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
