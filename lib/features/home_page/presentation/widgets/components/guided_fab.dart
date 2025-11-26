import 'package:flutter/material.dart';
import 'animated_arrow_pointer.dart';

/// Wrap any FAB widget and draw an animated arrow pointing to it.
/// This ensures the arrow renders above the BottomNavigationBar since it
/// shares the same floatingActionButton slot.
class GuidedFloatingActionButton extends StatelessWidget {
  final Widget child;
  final bool showArrow;
  final double arrowDistance; // how far the arrow sits to the left of the FAB
  final Color? arrowColor;
  final double? arrowSize;

  const GuidedFloatingActionButton({
    super.key,
    required this.child,
    required this.showArrow,
    this.arrowDistance = 72,
    this.arrowColor,
    this.arrowSize,
  });

  @override
  Widget build(BuildContext context) {
    if (!showArrow) return child;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        // Place arrow to the left of the FAB, vertically centered
        Positioned(
          left: -arrowDistance,
          child: IgnorePointer(
            child: AnimatedArrowPointer(
              color: arrowColor,
              size: arrowSize,
            ),
          ),
        ),
      ],
    );
  }
}

