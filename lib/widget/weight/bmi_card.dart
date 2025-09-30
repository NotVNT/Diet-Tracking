import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'weight_responsive_design.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

class BmiCard extends StatelessWidget {
  final double bmi;
  final String description;
  const BmiCard({super.key, required this.bmi, required this.description});

  @override
  Widget build(BuildContext context) {
    final r = WeightResponsive.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.space(12)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bmi == 0 ? '--' : bmi.toStringAsFixed(1),
            style: GoogleFonts.inter(
              fontSize: r.font(26),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3B82F6),
            ),
          ),
          SizedBox(width: r.space(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.bmiCurrentTitle ??
                          'BMI hiện tại của bạn',
                      style: GoogleFonts.inter(
                        fontSize: r.font(12),
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    SizedBox(width: r.space(4)),
                    Icon(
                      Icons.info_outline,
                      size: r.font(14),
                      color: const Color(0xFF9CA3AF),
                    ),
                  ],
                ),
                SizedBox(height: r.space(2)),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: r.font(11.5),
                    height: 1.35,
                    color: const Color(0xFF6B7280),
                  ),
                  maxLines: 2,
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
