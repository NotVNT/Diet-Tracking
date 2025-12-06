import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppStyles {
  // Text Styles
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    height: 1.2,
  );

  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
    height: 1.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
    height: 1.4,
  );

  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.grey600,
    height: 1.4,
  );

  static TextStyle get labelMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle get linkText => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  // Input Styles
  static InputDecoration get inputDecoration => InputDecoration(
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  static InputDecoration inputDecorationWithHint(String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: AppColors.grey500, fontSize: 16),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      );

  // Box Decorations
  // Tối ưu hóa: Giảm blur radius và offset để giảm rendering overhead
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withAlpha(20), // 0.08 * 255
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get inputBoxDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.grey300, width: 1.5),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadowLight.withAlpha(13), // 0.05 * 255
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration inputDecorationWithFocus(bool isFocused) =>
      BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? AppColors.primary : AppColors.grey300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isFocused
                ? AppColors.primary.withAlpha(20) // 0.08 * 255
                : AppColors.shadowLight.withAlpha(13), // 0.05 * 255
            blurRadius: isFocused ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      );

  static BoxDecoration get buttonDecoration => BoxDecoration(
    gradient: const LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withAlpha(31), // 0.12 * 255
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration get disabledButtonDecoration => BoxDecoration(
    color: AppColors.grey300,
    borderRadius: BorderRadius.circular(16),
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 40.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
}
