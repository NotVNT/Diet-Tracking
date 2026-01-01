import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../utils/bottom_sheet_utils.dart';
import 'package:google_fonts/google_fonts.dart';

class ScannerHelpSheet extends StatelessWidget {
  const ScannerHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.foodScannerHelpTitle,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...[
            l10n.foodScannerHelpTip1,
            l10n.foodScannerHelpTip2,
            l10n.foodScannerHelpTip3,
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showCustomBottomSheet<void>(
      context: context,
      backgroundColor: Colors.black,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const ScannerHelpSheet(),
    );
  }
}


