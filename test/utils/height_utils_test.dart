import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/utils/height_utils.dart';

void main() {
  group('convertToFeetInches', () {
    test('returns 0\'0" for 0 cm', () {
      expect(convertToFeetInches(0), "0'0\"");
    });

    test('rounds inches correctly for 170 cm -> 5\'7"', () {
      expect(convertToFeetInches(170), "5'7\"");
    });

    test('rounds inches correctly for 172 cm -> 5\'8"', () {
      expect(convertToFeetInches(172), "5'8\"");
    });
  });

  group('cmToFeetInches', () {
    test('returns feet and inches map with correct rounding', () {
      final result = cmToFeetInches(170);
      expect(result['feet'], 5);
      expect(result['inches'], 7);
    });

    test('handles edge case when rounding pushes inches to 12', () {
      // Choose cm so that inches rounds to 12 (e.g., 182.88 cm = exactly 6\'0")
      // But with rounding logic, a value just below the threshold should still be consistent
      final result = cmToFeetInches(182.88);
      expect(result['feet'], 6);
      expect(result['inches'], 0);
    });
  });

  group('feetInchesToCm', () {
    test('converts 5 ft 7 in to approximately 170.18 cm', () {
      final cm = feetInchesToCm(5, 7);
      expect(cm, closeTo(170.18, 0.01));
    });

    test('converts 0 ft 0 in to 0 cm', () {
      final cm = feetInchesToCm(0, 0);
      expect(cm, 0);
    });
  });

  group('formatHeight', () {
    test('formats in cm with one decimal place when isCm is true', () {
      expect(formatHeight(170.123, true), '170.1 cm');
      expect(formatHeight(170.05, true), '170.1 cm');
      expect(formatHeight(170.04, true), '170.0 cm');
    });

    test('formats in feet and inches when isCm is false', () {
      expect(formatHeight(170, false), "5'7\"");
      expect(formatHeight(182.88, false), "6'0\"");
    });
  });

  group('cmToDecimalFeet', () {
    test('converts 172 cm to decimal feet (~5.643)', () {
      final ft = cmToDecimalFeet(172);
      expect(ft, closeTo(5.643, 0.001));
    });

    test('converts 0 cm to 0 ft', () {
      final ft = cmToDecimalFeet(0);
      expect(ft, 0);
    });
  });
}
