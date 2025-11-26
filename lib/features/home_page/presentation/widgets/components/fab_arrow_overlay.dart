import 'package:flutter/material.dart';
import '../../../../../responsive/responsive.dart';
import 'animated_arrow_pointer.dart';

/// Overlay that shows a cool animated horizontal arrow pointing to the center FAB.
///
/// - Non-intrusive: wrapped in IgnorePointer, doesn't block touches.
/// - Easy to maintain: encapsulated and configurable via properties.
/// - Reusable across screens with a center-docked FAB.
class FabArrowOverlay extends StatelessWidget {
  final bool visible;
  final double? leftOffsetFromCenter; // positive value moves arrow to the left of center (in px)
  final double? bottomPadding; // space above bottom edge (to avoid BottomNav + FAB)
  final Color? color;
  final double? arrowSize;

  const FabArrowOverlay({
    super.key,
    required this.visible,
    this.leftOffsetFromCenter,
    this.bottomPadding,
    this.color,
    this.arrowSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    final responsive = ResponsiveHelper.of(context);
    final media = MediaQuery.of(context);

    // Default offsets that place arrow above BottomNav and pointing to center FAB
    final double defaultLeft = responsive.width(110);
    final double defaultBottom = media.padding.bottom + kBottomNavigationBarHeight + responsive.height(56);

    final double leftOffset = leftOffsetFromCenter ?? defaultLeft;
    final double bottom = bottomPadding ?? defaultBottom;

    return IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: Transform.translate(
            offset: Offset(-leftOffset, 0),
            child: AnimatedArrowPointer(
              color: color,
              size: arrowSize ?? responsive.width(64),
            ),
          ),
        ),
      ),
    );
  }
}

