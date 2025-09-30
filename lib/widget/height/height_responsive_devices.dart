import 'package:flutter/material.dart';

/// Responsive helpers for the height picker UI.
///
/// Baseline: iPhone 12 (390 x 844 logical pixels)
/// - widthScale and heightScale are clamped to avoid extremes
/// - scale() is the average of width and height scales
/// - Use dim() for generic sizes and font() for text sizes
class HeightResponsiveDevices {
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  /// Width-based scale factor, clamped for very small/large phones
  static double widthScale(
    BuildContext context, {
    double min = 0.80,
    double max = 1.35,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final s = width / _baseWidth;
    return s.clamp(min, max);
  }

  /// Height-based scale factor, clamped for very small/large phones
  static double heightScale(
    BuildContext context, {
    double min = 0.80,
    double max = 1.35,
  }) {
    final height = MediaQuery.sizeOf(context).height;
    final s = height / _baseHeight;
    return s.clamp(min, max);
  }

  /// Average of width and height scales for balanced scaling
  static double scale(
    BuildContext context, {
    double min = 0.80,
    double max = 1.35,
  }) {
    final ws = widthScale(context, min: min, max: max);
    final hs = heightScale(context, min: min, max: max);
    final avg = (ws + hs) / 2.0;
    return avg.clamp(min, max);
  }

  /// Scale a generic dimension by the average scale and clamp to a range
  static double dim(
    BuildContext context,
    double base, {
    double? min,
    double? max,
  }) {
    final s = scale(context);
    final value = base * s;
    if (min != null || max != null) {
      return value.clamp(min ?? value, max ?? value);
    }
    return value;
  }

  /// Scale a font size by the average scale and clamp to a sensible range
  static double font(
    BuildContext context,
    double base, {
    double min = 12,
    double max = 64,
  }) {
    final s = scale(context);
    return (base * s).clamp(min, max).toDouble();
  }

  /// Recommended wheel height based on device height
  static double wheelHeight(
    BuildContext context, {
    double base = 400,
    double min = 260,
    double max = 560,
  }) {
    final hs = heightScale(context);
    return (base * hs).clamp(min, max).toDouble();
  }
}

/// Optional extensions for ergonomic usage
extension HeightResponsiveNumX on num {
  double hDim(BuildContext context, {double? min, double? max}) =>
      HeightResponsiveDevices.dim(context, toDouble(), min: min, max: max);
  double hFont(BuildContext context, {double min = 12, double max = 64}) =>
      HeightResponsiveDevices.font(context, toDouble(), min: min, max: max);
}
