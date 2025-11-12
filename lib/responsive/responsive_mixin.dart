import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// A mixin that provides responsive capabilities to StatefulWidget
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  ResponsiveHelper get responsive => ResponsiveHelper.of(context);
  
  /// Get responsive width
  double rWidth(double base) => responsive.width(base);
  
  /// Get responsive height
  double rHeight(double base) => responsive.height(base);
  
  /// Get responsive dimension
  double rDimension(double base) => responsive.dimension(base);
  
  /// Get responsive font size
  double rFontSize(double base) => responsive.fontSize(base);
  
  /// Get responsive icon size
  double rIconSize(double base) => responsive.iconSize(base);
  
  /// Get responsive spacing
  double rSpacing(double base) => responsive.spacing(base);
  
  /// Get responsive radius
  double rRadius(double base) => responsive.radius(base);
  
  /// Get responsive padding
  EdgeInsets rPadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => responsive.edgePadding(
    all: all,
    horizontal: horizontal,
    vertical: vertical,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
  
  /// Get responsive vertical space
  SizedBox rVerticalSpace(double base) => responsive.verticalSpace(base);
  
  /// Get responsive horizontal space
  SizedBox rHorizontalSpace(double base) => responsive.horizontalSpace(base);
  
  /// Get responsive text style
  TextStyle rTextStyle(TextStyle base) => responsive.textStyle(base);
  
  /// Check device type
  DeviceType get deviceType => responsive.deviceType;
  
  /// Check if small phone
  bool get isSmallPhone => deviceType == DeviceType.smallPhone;
  
  /// Check if phone
  bool get isPhone => deviceType == DeviceType.phone || deviceType == DeviceType.largePhone;
  
  /// Check if tablet
  bool get isTablet => deviceType == DeviceType.tablet || deviceType == DeviceType.smallTablet;
  
  /// Check orientation
  bool get isPortrait => responsive.isPortrait;
  bool get isLandscape => responsive.isLandscape;
  
  /// Safe area paddings
  double get topSafeArea => responsive.topSafeArea;
  double get bottomSafeArea => responsive.bottomSafeArea;
}

/// A base class for StatelessWidget with responsive capabilities
abstract class ResponsiveStatelessWidget extends StatelessWidget {
  const ResponsiveStatelessWidget({super.key});
  
  ResponsiveHelper responsive(BuildContext context) => ResponsiveHelper.of(context);
  
  /// Get responsive width
  double rWidth(BuildContext context, double base) => responsive(context).width(base);
  
  /// Get responsive height
  double rHeight(BuildContext context, double base) => responsive(context).height(base);
  
  /// Get responsive dimension
  double rDimension(BuildContext context, double base) => responsive(context).dimension(base);
  
  /// Get responsive font size
  double rFontSize(BuildContext context, double base) => responsive(context).fontSize(base);
  
  /// Get responsive icon size
  double rIconSize(BuildContext context, double base) => responsive(context).iconSize(base);
  
  /// Get responsive spacing
  double rSpacing(BuildContext context, double base) => responsive(context).spacing(base);
  
  /// Get responsive radius
  double rRadius(BuildContext context, double base) => responsive(context).radius(base);
  
  /// Get responsive padding
  EdgeInsets rPadding(
    BuildContext context, {
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) => responsive(context).edgePadding(
    all: all,
    horizontal: horizontal,
    vertical: vertical,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
  
  /// Get responsive vertical space
  SizedBox rVerticalSpace(BuildContext context, double base) => responsive(context).verticalSpace(base);
  
  /// Get responsive horizontal space
  SizedBox rHorizontalSpace(BuildContext context, double base) => responsive(context).horizontalSpace(base);
  
  /// Get responsive text style
  TextStyle rTextStyle(BuildContext context, TextStyle base) => responsive(context).textStyle(base);
  
  /// Check device type
  DeviceType deviceType(BuildContext context) => responsive(context).deviceType;
  
  /// Check if small phone
  bool isSmallPhone(BuildContext context) => deviceType(context) == DeviceType.smallPhone;
  
  /// Check if phone
  bool isPhone(BuildContext context) {
    final type = deviceType(context);
    return type == DeviceType.phone || type == DeviceType.largePhone;
  }
  
  /// Check if tablet
  bool isTablet(BuildContext context) {
    final type = deviceType(context);
    return type == DeviceType.tablet || type == DeviceType.smallTablet;
  }
}

/// A wrapper widget that makes any child responsive-aware
class ResponsiveWrapper extends StatelessWidget {
  final Widget Function(BuildContext context, ResponsiveHelper responsive) builder;
  
  const ResponsiveWrapper({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return builder(context, ResponsiveHelper.of(context));
  }
}

/// A scaffold with automatic responsive padding
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final double? basePadding;
  final bool applySafeArea;
  
  const ResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.basePadding,
    this.applySafeArea = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    Widget responsiveBody = body;
    
    if (basePadding != null) {
      responsiveBody = Padding(
        padding: EdgeInsets.all(responsive.spacing(basePadding!)),
        child: body,
      );
    }
    
    if (applySafeArea) {
      responsiveBody = SafeArea(child: responsiveBody);
    }
    
    return Scaffold(
      appBar: appBar,
      body: responsiveBody,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      drawer: drawer,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}
