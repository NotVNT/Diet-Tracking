import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnitToggle extends StatelessWidget {
  final bool isKg;
  final ValueChanged<bool> onChanged; // true -> kg, false -> lb

  const UnitToggle({super.key, required this.isKg, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // Match height selector toggle colors: selected black bg with white text,
    // unselected transparent with dark text inside a light grey capsule.
    final Color capsuleBg = Colors.grey.shade200;
    final Color selectedBg = Colors.black;
    final Color selectedText = Colors.white;
    final Color unselectedBg = Colors.transparent;
    final Color unselectedText = Colors.black87;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: capsuleBg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChip(
            label: 'kg',
            selected: isKg,
            bgActive: selectedBg,
            textActive: selectedText,
            bgInactive: unselectedBg,
            textInactive: unselectedText,
            onTap: () => onChanged(true),
          ),
          const SizedBox(width: 6),
          _buildChip(
            label: 'lb',
            selected: !isKg,
            bgActive: selectedBg,
            textActive: selectedText,
            bgInactive: unselectedBg,
            textInactive: unselectedText,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required Color bgActive,
    required Color textActive,
    required Color bgInactive,
    required Color textInactive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? bgActive : bgInactive,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? textActive : textInactive,
          ),
        ),
      ),
    );
  }
}
