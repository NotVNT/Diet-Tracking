import 'package:flutter/material.dart';
import '../../../../responsive/responsive.dart';

/// Small rounded button to open filters. Designed to be placed next to SearchBar
class FilterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool highlighted; // when any filter is active

  const FilterButton({
    super.key,
    this.onPressed,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    final bg = highlighted
        ? theme.colorScheme.primary
        : theme.colorScheme.primary.withValues(alpha: 0.85);

    return SizedBox(
      height: responsive.height(48),
      width: responsive.height(48),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          child: Center(
            child: Icon(
              Icons.tune_rounded,
              color: theme.colorScheme.onPrimary,
              size: responsive.iconSize(20),
            ),
          ),
        ),
      ),
    );
  }
}

