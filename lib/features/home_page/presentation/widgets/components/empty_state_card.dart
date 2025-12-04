import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';

/// A simple, reusable empty state card.
///
/// Use this to display an informative message when a section has no data.
/// Designed to be lightweight, easy to maintain and scale.
class EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? minHeight;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Widget? footer; // Optional widget below the subtitle (e.g. arrow, CTA)

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.minHeight,
    this.padding,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final cardContent = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.fontSize(16),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: responsive.height(6)),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.fontSize(14),
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
          ),
        ),
        if (footer != null) ...[
          SizedBox(height: responsive.height(12)),
          footer!,
        ]
      ],
    );

    final child = Padding(
      padding: padding ?? EdgeInsets.all(responsive.width(16)),
      child: Center(child: cardContent),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight ?? responsive.height(120)),
      child: InkWell(
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(responsive.radius(16)),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

