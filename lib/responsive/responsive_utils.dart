import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// Utility class to help with common responsive patterns
class ResponsiveUtils {
  /// Get responsive padding for common use cases
  static EdgeInsets screenPadding(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return responsive.edgePadding(horizontal: 16, vertical: 16);
  }

  /// Get responsive padding for card content
  static EdgeInsets cardPadding(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return responsive.edgePadding(all: 16);
  }

  /// Get responsive padding for list items
  static EdgeInsets listItemPadding(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return responsive.edgePadding(horizontal: 16, vertical: 12);
  }

  /// Get responsive spacing between sections
  static double sectionSpacing(BuildContext context) {
    return ResponsiveHelper.of(context).spacing(24);
  }

  /// Get responsive spacing between items
  static double itemSpacing(BuildContext context) {
    return ResponsiveHelper.of(context).spacing(16);
  }

  /// Get responsive spacing between elements
  static double elementSpacing(BuildContext context) {
    return ResponsiveHelper.of(context).spacing(8);
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context) {
    return ResponsiveHelper.of(context).height(50);
  }

  /// Get responsive input field height
  static double inputHeight(BuildContext context) {
    return ResponsiveHelper.of(context).height(56);
  }

  /// Get responsive app bar height
  static double appBarHeight(BuildContext context) {
    return ResponsiveHelper.of(context).height(kToolbarHeight);
  }

  /// Get responsive icon size for different use cases
  static double iconSizeSmall(BuildContext context) {
    return ResponsiveHelper.of(context).iconSize(16);
  }

  static double iconSizeMedium(BuildContext context) {
    return ResponsiveHelper.of(context).iconSize(24);
  }

  static double iconSizeLarge(BuildContext context) {
    return ResponsiveHelper.of(context).iconSize(32);
  }

  /// Get responsive font sizes for typography
  static double fontSizeCaption(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(12);
  }

  static double fontSizeBody(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(14);
  }

  static double fontSizeBodyLarge(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(16);
  }

  static double fontSizeHeading(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(20);
  }

  static double fontSizeTitle(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(24);
  }

  static double fontSizeDisplay(BuildContext context) {
    return ResponsiveHelper.of(context).fontSize(32);
  }

  /// Get responsive border radius for different use cases
  static double radiusSmall(BuildContext context) {
    return ResponsiveHelper.of(context).radius(4);
  }

  static double radiusMedium(BuildContext context) {
    return ResponsiveHelper.of(context).radius(8);
  }

  static double radiusLarge(BuildContext context) {
    return ResponsiveHelper.of(context).radius(12);
  }

  static double radiusXLarge(BuildContext context) {
    return ResponsiveHelper.of(context).radius(16);
  }

  static double radiusCircular(BuildContext context) {
    return ResponsiveHelper.of(context).radius(999);
  }

  /// Get responsive dimensions for common UI elements
  static Size avatarSizeSmall(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return Size(responsive.dimension(32), responsive.dimension(32));
  }

  static Size avatarSizeMedium(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return Size(responsive.dimension(48), responsive.dimension(48));
  }

  static Size avatarSizeLarge(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return Size(responsive.dimension(64), responsive.dimension(64));
  }

  /// Get responsive grid configurations
  static int gridCrossAxisCount(BuildContext context, {int? phone, int? tablet}) {
    final responsive = ResponsiveHelper.of(context);
    
    switch (responsive.deviceType) {
      case DeviceType.smallPhone:
        return 1;
      case DeviceType.phone:
      case DeviceType.largePhone:
        return phone ?? 2;
      case DeviceType.smallTablet:
        return tablet ?? 3;
      case DeviceType.tablet:
        return tablet ?? 4;
    }
  }

  /// Get responsive max width for content
  static double maxContentWidth(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    switch (responsive.deviceType) {
      case DeviceType.smallPhone:
      case DeviceType.phone:
      case DeviceType.largePhone:
        return responsive.screenWidth;
      case DeviceType.smallTablet:
        return responsive.width(600);
      case DeviceType.tablet:
        return responsive.width(800);
    }
  }

  /// Get responsive dialog width
  static double dialogWidth(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    switch (responsive.deviceType) {
      case DeviceType.smallPhone:
        return responsive.screenWidth * 0.9;
      case DeviceType.phone:
      case DeviceType.largePhone:
        return responsive.screenWidth * 0.85;
      case DeviceType.smallTablet:
        return responsive.width(500);
      case DeviceType.tablet:
        return responsive.width(600);
    }
  }

  /// Check if should use single column layout
  static bool shouldUseSingleColumn(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return responsive.deviceType == DeviceType.smallPhone ||
           responsive.deviceType == DeviceType.phone;
  }

  /// Get responsive bottom sheet max height
  static double bottomSheetMaxHeight(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    return responsive.screenHeight * 0.85;
  }

  /// Get responsive minimum touch target size
  static double minTouchTarget(BuildContext context) {
    return ResponsiveHelper.of(context).dimension(44);
  }

  /// Create responsive BoxConstraints
  static BoxConstraints responsiveConstraints(
    BuildContext context, {
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) {
    final responsive = ResponsiveHelper.of(context);
    
    return BoxConstraints(
      minWidth: minWidth != null ? responsive.width(minWidth) : 0,
      maxWidth: maxWidth != null ? responsive.width(maxWidth) : double.infinity,
      minHeight: minHeight != null ? responsive.height(minHeight) : 0,
      maxHeight: maxHeight != null ? responsive.height(maxHeight) : double.infinity,
    );
  }

  /// Get responsive text theme
  static TextTheme responsiveTextTheme(BuildContext context, TextTheme baseTheme) {
    final responsive = ResponsiveHelper.of(context);
    
    return TextTheme(
      displayLarge: baseTheme.displayLarge?.copyWith(
        fontSize: responsive.fontSize(baseTheme.displayLarge?.fontSize ?? 57),
      ),
      displayMedium: baseTheme.displayMedium?.copyWith(
        fontSize: responsive.fontSize(baseTheme.displayMedium?.fontSize ?? 45),
      ),
      displaySmall: baseTheme.displaySmall?.copyWith(
        fontSize: responsive.fontSize(baseTheme.displaySmall?.fontSize ?? 36),
      ),
      headlineLarge: baseTheme.headlineLarge?.copyWith(
        fontSize: responsive.fontSize(baseTheme.headlineLarge?.fontSize ?? 32),
      ),
      headlineMedium: baseTheme.headlineMedium?.copyWith(
        fontSize: responsive.fontSize(baseTheme.headlineMedium?.fontSize ?? 28),
      ),
      headlineSmall: baseTheme.headlineSmall?.copyWith(
        fontSize: responsive.fontSize(baseTheme.headlineSmall?.fontSize ?? 24),
      ),
      titleLarge: baseTheme.titleLarge?.copyWith(
        fontSize: responsive.fontSize(baseTheme.titleLarge?.fontSize ?? 22),
      ),
      titleMedium: baseTheme.titleMedium?.copyWith(
        fontSize: responsive.fontSize(baseTheme.titleMedium?.fontSize ?? 16),
      ),
      titleSmall: baseTheme.titleSmall?.copyWith(
        fontSize: responsive.fontSize(baseTheme.titleSmall?.fontSize ?? 14),
      ),
      bodyLarge: baseTheme.bodyLarge?.copyWith(
        fontSize: responsive.fontSize(baseTheme.bodyLarge?.fontSize ?? 16),
      ),
      bodyMedium: baseTheme.bodyMedium?.copyWith(
        fontSize: responsive.fontSize(baseTheme.bodyMedium?.fontSize ?? 14),
      ),
      bodySmall: baseTheme.bodySmall?.copyWith(
        fontSize: responsive.fontSize(baseTheme.bodySmall?.fontSize ?? 12),
      ),
      labelLarge: baseTheme.labelLarge?.copyWith(
        fontSize: responsive.fontSize(baseTheme.labelLarge?.fontSize ?? 14),
      ),
      labelMedium: baseTheme.labelMedium?.copyWith(
        fontSize: responsive.fontSize(baseTheme.labelMedium?.fontSize ?? 12),
      ),
      labelSmall: baseTheme.labelSmall?.copyWith(
        fontSize: responsive.fontSize(baseTheme.labelSmall?.fontSize ?? 11),
      ),
    );
  }
}
