import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WeightDisplay extends StatelessWidget {
  final String valueText; // e.g. 130.5
  final String unit; // kg or lb
  const WeightDisplay({super.key, required this.valueText, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valueText,
          style: GoogleFonts.inter(
            fontSize: 56,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          unit,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
