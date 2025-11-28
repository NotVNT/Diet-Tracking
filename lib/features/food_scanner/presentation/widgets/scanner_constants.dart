import 'package:flutter/material.dart';

/// Centralized numeric constants and paddings used by scanner UI widgets.
class ScannerDims {
  // Spacing
  static const double xxs = 4;
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  // Buttons / radius
  static const double actionButtonRadius = 16;
  static const double toolbarButtonRadius = 12;
  static const double toolbarButtonSize = 40;
  static const double toolbarIconSize = 22;

  // Capture button
  static const double captureOuter = 76;
  static const double captureInner = 56;
  static const double actionBorderWidth = 1.5;
  static const double scanningFrameBorderWidth = 3;

  // Banner
  static const EdgeInsets bannerPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 16);
}

/// Durations and curves used for scanner widgets.
class ScannerDurations {
  static const actionSwitch = Duration(milliseconds: 200);
}

/// Default parameters for barcode scanning frame size calculation.
class BarcodeFrameDefaults {
  static const double minWidth = 220;
  static const double widthRatio = 0.75;
  static const double widthToHeightRatio = 2.4;
  static const double minHeight = 110;
  static const double maxHeightFactor = 0.45; // 45% of screen height
  static const double horizontalPadding = 32; // 16 left + 16 right visual spacing
}




