import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;

/// Reusable square rounded IconButton wrapped by `badges` to easily position
/// it in complex layouts. Kept in a separate file for maintainability and tests.
class AddBadgeIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final String semanticLabel;
  final String tooltip;
  final IconData icon;
  final Color? badgeColor;

  const AddBadgeIconButton({
    super.key,
    this.onPressed,
    this.size = 40,
    this.borderRadius = 10,
    this.semanticLabel = 'add-food-scanned',
    this.tooltip = 'Add food scanned',
    this.icon = Icons.add,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticLabel,
      button: true,
      child: badges.Badge(
        position: badges.BadgePosition.center(),
        badgeStyle: badges.BadgeStyle(
          shape: badges.BadgeShape.square,
          borderRadius: BorderRadius.circular(borderRadius),
          badgeColor: badgeColor ?? theme.colorScheme.surfaceContainerHighest,
          elevation: 0,
          padding: EdgeInsets.zero,
        ),
        badgeContent: SizedBox(
          width: size,
          height: size,
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: size, height: size),
            onPressed: onPressed,
            icon: Icon(icon),
            iconSize: 22,
            tooltip: tooltip,
          ),
        ),
        // child is required by the badges API but unused in this case.
        child: SizedBox(width: size, height: size),
      ),
    );
  }
}

