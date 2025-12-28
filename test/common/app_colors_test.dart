import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Primary Colors', () {
      test('should have correct primary color', () {
        expect(AppColors.primary, const Color(0xFF9C27B0));
      });

      test('should have correct primary light color', () {
        expect(AppColors.primaryLight, const Color(0xFFE1BEE7));
      });

      test('should have correct primary dark color', () {
        expect(AppColors.primaryDark, const Color(0xFF7B1FA2));
      });
    });

    group('Secondary Colors', () {
      test('should have correct secondary color', () {
        expect(AppColors.secondary, const Color(0xFF673AB7));
      });

      test('should have correct secondary light color', () {
        expect(AppColors.secondaryLight, const Color(0xFFD1C4E9));
      });
    });

    group('Gradient Colors', () {
      test('should have correct primary gradient colors', () {
        expect(AppColors.primaryGradient, [
          const Color(0xFF9C27B0),
          const Color(0xFF673AB7),
        ]);
      });

      test('should have correct background gradient colors', () {
        expect(AppColors.backgroundGradient, [
          const Color(0xFFF8F9FF),
          const Color(0xFFE8EAF6),
          const Color(0xFFF3E5F5),
        ]);
      });

      test('should have correct card gradient colors', () {
        expect(AppColors.cardGradient, [
          const Color(0xFFFFFFFF),
          const Color(0xFFFAFAFA),
        ]);
      });
    });

    group('Neutral Colors', () {
      test('should have correct white color', () {
        expect(AppColors.white, const Color(0xFFFFFFFF));
      });

      test('should have correct black color', () {
        expect(AppColors.black, const Color(0xFF000000));
      });

      test('should have correct grey scale colors', () {
        expect(AppColors.grey50, const Color(0xFFFAFAFA));
        expect(AppColors.grey100, const Color(0xFFF5F5F5));
        expect(AppColors.grey200, const Color(0xFFEEEEEE));
        expect(AppColors.grey300, const Color(0xFFE0E0E0));
        expect(AppColors.grey400, const Color(0xFFBDBDBD));
        expect(AppColors.grey500, const Color(0xFF9E9E9E));
        expect(AppColors.grey600, const Color(0xFF757575));
        expect(AppColors.grey700, const Color(0xFF616161));
        expect(AppColors.grey800, const Color(0xFF424242));
        expect(AppColors.grey900, const Color(0xFF212121));
      });
    });

    group('Status Colors', () {
      test('should have correct success color', () {
        expect(AppColors.success, const Color(0xFF4CAF50));
      });

      test('should have correct warning color', () {
        expect(AppColors.warning, const Color(0xFFFF9800));
      });

      test('should have correct error color', () {
        expect(AppColors.error, const Color(0xFFF44336));
      });

      test('should have correct info color', () {
        expect(AppColors.info, const Color(0xFF2196F3));
      });
    });

    group('Shadow Colors', () {
      test('should have correct shadow light color', () {
        expect(AppColors.shadowLight, const Color(0x0A000000));
      });

      test('should have correct shadow medium color', () {
        expect(AppColors.shadowMedium, const Color(0x14000000));
      });

      test('should have correct shadow dark color', () {
        expect(AppColors.shadowDark, const Color(0x1F000000));
      });
    });

    group('Color Properties', () {
      test('should have correct opacity values for shadow colors', () {
        // New Color component accessors return 0..1 doubles.
        // Our const colors are ARGB: 0x0A000000, 0x14000000, 0x1F000000.
        expect(AppColors.shadowLight.a, closeTo(0x0A / 255.0, 0.001));
        expect(AppColors.shadowMedium.a, closeTo(0x14 / 255.0, 0.001));
        expect(AppColors.shadowDark.a, closeTo(0x1F / 255.0, 0.001));
      });

      test('should have correct color values for status colors', () {
        // Use toARGB32() instead of deprecated .value
        expect(AppColors.success.toARGB32(), 0xFF4CAF50);
        expect(AppColors.warning.toARGB32(), 0xFFFF9800);
        expect(AppColors.error.toARGB32(), 0xFFF44336);
        expect(AppColors.info.toARGB32(), 0xFF2196F3);
      });
    });
  });
}
