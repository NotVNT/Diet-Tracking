import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable colors used by scanner widgets.
class ScannerColors {
  static const Color white = Colors.white;
  static const Color white70 = Colors.white70;
  static const Color white12 = Colors.white12;
  static const Color white24 = Colors.white24;
  static const Color black = Colors.black;
  static const Color green = Colors.green;
}

/// Centralized text styles for scanner UI.
class ScannerTextStyles {
  static TextStyle title() => GoogleFonts.inter(
        color: ScannerColors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle subtitle() => GoogleFonts.inter(
        color: ScannerColors.white70,
        fontSize: 14,
      );

  static TextStyle actionLabel({required bool selected}) => GoogleFonts.inter(
        color: selected ? ScannerColors.black : ScannerColors.white,
        fontWeight: FontWeight.w600,
        fontSize: 11,
      );

  static TextStyle scanningBanner(TextStyle base) => base.copyWith(
        color: ScannerColors.white,
        fontWeight: FontWeight.w600,
      );
}

/// Decorations for buttons and containers.
class ScannerDecorations {
  static BoxDecoration actionButton({required bool selected, required double radius, required double borderWidth}) =>
      BoxDecoration(
        color: selected ? ScannerColors.white : ScannerColors.white12,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: selected ? ScannerColors.white : ScannerColors.white24,
          width: borderWidth,
        ),
      );

  static BoxDecoration toolbarButton(double radius) => BoxDecoration(
        color: ScannerColors.white12,
        borderRadius: BorderRadius.circular(radius),
      );

  static BoxDecoration scanningBanner() => BoxDecoration(
        color: ScannerColors.green.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      );

  static BoxDecoration captureOuter() => BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white54, width: 3),
      );

  static BoxDecoration captureInner({required bool isGallery}) => BoxDecoration(
        shape: BoxShape.circle,
        color: isGallery ? Colors.white10 : Colors.white,
        border: isGallery ? Border.all(color: Colors.white, width: 2) : null,
      );
}

