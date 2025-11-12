import 'package:flutter/material.dart';
import 'responsive_helper.dart';

/// A widget that builds different layouts based on device type
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType)? builder;
  final Widget? smallPhone;
  final Widget? phone;
  final Widget? largePhone;
  final Widget? tablet;
  final Widget mobile;

  const ResponsiveBuilder({
    super.key,
    this.builder,
    this.smallPhone,
    this.phone,
    this.largePhone,
    this.tablet,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final deviceType = responsive.deviceType;

    if (builder != null) {
      return builder!(context, deviceType);
    }

    switch (deviceType) {
      case DeviceType.smallPhone:
        return smallPhone ?? phone ?? mobile;
      case DeviceType.phone:
        return phone ?? mobile;
      case DeviceType.largePhone:
        return largePhone ?? phone ?? mobile;
      case DeviceType.smallTablet:
      case DeviceType.tablet:
        return tablet ?? largePhone ?? mobile;
    }
  }
}

/// A responsive container that adjusts padding and sizing
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? basePadding;
  final double? baseWidth;
  final double? baseHeight;
  final Color? color;
  final Decoration? decoration;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry? customPadding;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.basePadding,
    this.baseWidth,
    this.baseHeight,
    this.color,
    this.decoration,
    this.alignment,
    this.customPadding,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return Container(
      width: baseWidth != null ? responsive.width(baseWidth!) : null,
      height: baseHeight != null ? responsive.height(baseHeight!) : null,
      padding: customPadding ?? 
               (basePadding != null ? EdgeInsets.all(responsive.spacing(basePadding!)) : null),
      color: color,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// A responsive text widget
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final responsiveStyle = style != null ? responsive.textStyle(style!) : null;

    return Text(
      text,
      style: responsiveStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

/// A responsive card widget
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final double? baseRadius;
  final double? baseElevation;
  final double? basePadding;
  final Color? color;
  final EdgeInsetsGeometry? customPadding;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.baseRadius = 12.0,
    this.baseElevation = 2.0,
    this.basePadding = 16.0,
    this.color,
    this.customPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    final cardChild = Padding(
      padding: customPadding ?? EdgeInsets.all(responsive.spacing(basePadding!)),
      child: child,
    );

    return Card(
      elevation: baseElevation,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.radius(baseRadius!)),
      ),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(responsive.radius(baseRadius!)),
              child: cardChild,
            )
          : cardChild,
    );
  }
}

/// A responsive icon widget
class ResponsiveIcon extends StatelessWidget {
  final IconData icon;
  final double? baseSize;
  final Color? color;

  const ResponsiveIcon(
    this.icon, {
    super.key,
    this.baseSize = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return Icon(
      icon,
      size: responsive.iconSize(baseSize!),
      color: color,
    );
  }
}

/// A responsive button with adaptive sizing
class ResponsiveButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? baseHeight;
  final double? baseMinWidth;
  final double? basePadding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? baseRadius;
  final BorderSide? side;

  const ResponsiveButton({
    super.key,
    required this.child,
    this.onPressed,
    this.baseHeight = 50.0,
    this.baseMinWidth,
    this.basePadding = 16.0,
    this.backgroundColor,
    this.foregroundColor,
    this.baseRadius = 12.0,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return SizedBox(
      height: responsive.height(baseHeight!),
      width: baseMinWidth != null ? responsive.width(baseMinWidth!) : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(basePadding!),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(baseRadius!)),
            side: side ?? BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Responsive spacer widget
class ResponsiveSpacer extends StatelessWidget {
  final double? baseHeight;
  final double? baseWidth;

  const ResponsiveSpacer({
    super.key,
    this.baseHeight,
    this.baseWidth,
  }) : assert(baseHeight != null || baseWidth != null,
              'Either baseHeight or baseWidth must be provided');

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);

    return SizedBox(
      height: baseHeight != null ? responsive.spacing(baseHeight!) : null,
      width: baseWidth != null ? responsive.spacing(baseWidth!) : null,
    );
  }
}

/// Responsive grid view
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double baseChildAspectRatio;
  final double baseSpacing;
  final int? crossAxisCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.baseChildAspectRatio = 1.0,
    this.baseSpacing = 16.0,
    this.crossAxisCount,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    
    // Auto-calculate crossAxisCount based on device type if not provided
    final effectiveCrossAxisCount = crossAxisCount ?? _getDefaultCrossAxisCount(responsive.deviceType);

    return GridView.count(
      crossAxisCount: effectiveCrossAxisCount,
      childAspectRatio: baseChildAspectRatio,
      crossAxisSpacing: responsive.spacing(baseSpacing),
      mainAxisSpacing: responsive.spacing(baseSpacing),
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }

  int _getDefaultCrossAxisCount(DeviceType deviceType) {
    switch (deviceType) {
      case DeviceType.smallPhone:
        return 1;
      case DeviceType.phone:
      case DeviceType.largePhone:
        return 2;
      case DeviceType.smallTablet:
        return 3;
      case DeviceType.tablet:
        return 4;
    }
  }
}
