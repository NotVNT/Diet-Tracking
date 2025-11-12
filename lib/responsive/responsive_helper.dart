import 'package:flutter/material.dart';

/// Comprehensive responsive helper for the entire Diet Tracking app
/// 
/// Base design: iPhone 12 (390 x 844 logical pixels)
/// Supports: Small phones, standard phones, large phones, and tablets
class ResponsiveHelper {
  static const double _baseWidth = 390.0;
  static const double _baseHeight = 844.0;

  final BuildContext context;
  final Size _screenSize;

  ResponsiveHelper(this.context) : _screenSize = MediaQuery.of(context).size;

  /// Create from BuildContext
  static ResponsiveHelper of(BuildContext context) {
    return ResponsiveHelper(context);
  }

  /// Get screen width
  double get screenWidth => _screenSize.width;

  /// Get screen height
  double get screenHeight => _screenSize.height;

  /// Check if device is in portrait mode
  bool get isPortrait => _screenSize.height > _screenSize.width;

  /// Check if device is in landscape mode
  bool get isLandscape => _screenSize.width > _screenSize.height;

  /// Device type based on screen width
  DeviceType get deviceType {
    if (screenWidth < 360) return DeviceType.smallPhone;
    if (screenWidth < 400) return DeviceType.phone;
    if (screenWidth < 600) return DeviceType.largePhone;
    if (screenWidth < 900) return DeviceType.smallTablet;
    return DeviceType.tablet;
  }

  /// Width scale factor (clamped to avoid extremes)
  double get widthScale {
    final s = screenWidth / _baseWidth;
    return s.clamp(0.75, 1.5);
  }

  /// Height scale factor (clamped to avoid extremes)
  double get heightScale {
    final s = screenHeight / _baseHeight;
    return s.clamp(0.75, 1.5);
  }

  /// Average scale factor for balanced scaling
  double get scale {
    return ((widthScale + heightScale) / 2.0).clamp(0.75, 1.5);
  }

  /// Scale width dimension
  double width(double baseWidth) {
    return (baseWidth * widthScale).clamp(baseWidth * 0.8, baseWidth * 1.4);
  }

  /// Scale height dimension
  double height(double baseHeight) {
    return (baseHeight * heightScale).clamp(baseHeight * 0.8, baseHeight * 1.4);
  }

  /// Scale generic dimension using average scale
  double dimension(double baseDimension) {
    return (baseDimension * scale).clamp(baseDimension * 0.8, baseDimension * 1.4);
  }

  /// Scale font size
  double fontSize(double baseSize) {
    return (baseSize * scale).clamp(baseSize * 0.85, baseSize * 1.25);
  }

  /// Scale icon size
  double iconSize(double baseSize) {
    return (baseSize * scale).clamp(baseSize * 0.85, baseSize * 1.3);
  }

  /// Scale spacing (padding, margin)
  double spacing(double baseSpacing) {
    return (baseSpacing * scale).clamp(baseSpacing * 0.8, baseSpacing * 1.35);
  }

  /// Scale border radius
  double radius(double baseRadius) {
    return (baseRadius * scale).clamp(baseRadius * 0.8, baseRadius * 1.3);
  }

  /// Get responsive padding for edges
  EdgeInsets edgePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    if (all != null) {
      return EdgeInsets.all(spacing(all));
    }
    return EdgeInsets.only(
      left: spacing(left ?? horizontal ?? 0),
      top: spacing(top ?? vertical ?? 0),
      right: spacing(right ?? horizontal ?? 0),
      bottom: spacing(bottom ?? vertical ?? 0),
    );
  }

  /// Get responsive SizedBox for vertical spacing
  SizedBox verticalSpace(double baseHeight) {
    return SizedBox(height: spacing(baseHeight));
  }

  /// Get responsive SizedBox for horizontal spacing
  SizedBox horizontalSpace(double baseWidth) {
    return SizedBox(width: spacing(baseWidth));
  }

  /// Get responsive text style
  TextStyle textStyle(TextStyle baseStyle) {
    if (baseStyle.fontSize == null) return baseStyle;
    return baseStyle.copyWith(fontSize: fontSize(baseStyle.fontSize!));
  }

  /// Get safe area padding
  EdgeInsets get safeAreaPadding => MediaQuery.of(context).padding;

  /// Get bottom safe area (for keyboards, notches)
  double get bottomSafeArea => MediaQuery.of(context).padding.bottom;

  /// Get top safe area (for notches, status bar)
  double get topSafeArea => MediaQuery.of(context).padding.top;
}

/// Device type enumeration
enum DeviceType {
  smallPhone,  // < 360dp width
  phone,       // 360-400dp width
  largePhone,  // 400-600dp width
  smallTablet, // 600-900dp width
  tablet,      // > 900dp width
}

/// Extension for quick access to responsive helper
extension ResponsiveContext on BuildContext {
  ResponsiveHelper get responsive => ResponsiveHelper.of(this);
}
