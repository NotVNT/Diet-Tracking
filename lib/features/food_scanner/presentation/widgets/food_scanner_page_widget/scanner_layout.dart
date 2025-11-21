import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'scanner_constants.dart';

/// Calculator for barcode scanning frame size.
///
/// Keeps the original behavior while centralizing the logic and constants.
class BarcodeFrameCalculator {
  /// Returns an appropriate frame size that fits within the given viewport.
  ///
  /// - Width is based on a ratio of the viewport width (default 75%),
  ///   clamped by [BarcodeFrameDefaults.minWidth] and viewport minus padding.
  /// - Height is derived from width using a fixed width/height ratio,
  ///   and clamped to a minimum and a percentage of viewport height.
  static Size calculate({
    required double viewportWidth,
    required double viewportHeight,
  }) {
    // Width
    final maxAllowedWidth = math.max(
      viewportWidth - BarcodeFrameDefaults.horizontalPadding,
      BarcodeFrameDefaults.minWidth,
    );
    final targetWidth = viewportWidth * BarcodeFrameDefaults.widthRatio;
    final frameWidth = targetWidth
        .clamp(BarcodeFrameDefaults.minWidth, maxAllowedWidth)
        .toDouble();

    // Height
    final tentativeHeight =
        frameWidth / BarcodeFrameDefaults.widthToHeightRatio;
    final maxAllowedHeight = math.max(
      viewportHeight * BarcodeFrameDefaults.maxHeightFactor,
      BarcodeFrameDefaults.minHeight,
    );
    final frameHeight = tentativeHeight
        .clamp(BarcodeFrameDefaults.minHeight, maxAllowedHeight)
        .toDouble();

    return Size(frameWidth, frameHeight);
  }
}

