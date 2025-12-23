import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DaysSliderCard extends StatelessWidget {
  const DaysSliderCard({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
    this.minDays = 7,
    this.maxDays = 365,
    this.divisions = 51,
  });

  final int selectedDays;
  final ValueChanged<int> onDaysChanged;
  final int minDays;
  final int maxDays;
  final int divisions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '$selectedDays ngày',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2A37),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '≈ ${(selectedDays / 7).toStringAsFixed(1)} tuần',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Slider(
            value: selectedDays.toDouble(),
            min: minDays.toDouble(),
            max: maxDays.toDouble(),
            divisions: divisions,
            activeColor: const Color(0xFF1F2A37),
            onChanged: (value) => onDaysChanged(value.toInt()),
          ),
        ],
      ),
    );
  }
}
