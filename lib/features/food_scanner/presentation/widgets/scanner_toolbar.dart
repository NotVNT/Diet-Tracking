import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScannerToolbar extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onHelp;
  final VoidCallback onClose;

  const ScannerToolbar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onHelp,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ScannerToolbarIconButton(
                icon: Icons.help_outline,
                onPressed: onHelp,
              ),
              const Spacer(),
              _ScannerToolbarIconButton(
                icon: Icons.close,
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerToolbarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ScannerToolbarIconButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onPressed,
      radius: 24,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
