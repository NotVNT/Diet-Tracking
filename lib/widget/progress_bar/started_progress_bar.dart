import 'package:flutter/material.dart';

class StartedProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color? inactiveColor;
  final VoidCallback? onBack;
  final bool showBack;
  final EdgeInsetsGeometry padding;
  final double barHeight;
  final double segmentGap;
  final double backButtonSize;
  final double backIconSize;

  const StartedProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    this.inactiveColor,
    this.onBack,
    this.showBack = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.barHeight = 6,
    this.segmentGap = 8,
    this.backButtonSize = 40,
    this.backIconSize = 20,
  }) : assert(totalSteps > 0),
       assert(currentStep > 0),
       assert(currentStep <= totalSteps);

  @override
  Widget build(BuildContext context) {
    final effectiveInactive =
        inactiveColor ?? Colors.black.withValues(alpha: 0.08);

    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (showBack)
            _BackButton(
              size: backButtonSize,
              iconSize: backIconSize,
              activeColor: activeColor,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
            ),
          if (showBack) const SizedBox(width: 12),
          Expanded(
            child: _Segments(
              currentStep: currentStep,
              totalSteps: totalSteps,
              activeColor: activeColor,
              inactiveColor: effectiveInactive,
              barHeight: barHeight,
              gap: segmentGap,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;
  final double barHeight;
  final double gap;

  const _Segments({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
    required this.barHeight,
    required this.gap,
  });

  @override
  Widget build(BuildContext context) {
    if (totalSteps == 1) {
      return Container(
        height: barHeight,
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(barHeight),
        ),
      );
    }

    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          return SizedBox(width: gap);
        }

        final segmentIndex = i ~/ 2;
        final isActive = segmentIndex < currentStep;
        return Expanded(
          child: Container(
            height: barHeight,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(barHeight),
            ),
          ),
        );
      }),
    );
  }
}

class _BackButton extends StatelessWidget {
  final double size;
  final double iconSize;
  final Color activeColor;
  final VoidCallback onTap;

  const _BackButton({
    required this.size,
    required this.iconSize,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: activeColor.withValues(alpha: 0.10),
        shape: BoxShape.circle,
        border: Border.all(
          color: activeColor.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Icon(Icons.arrow_back, size: iconSize, color: activeColor),
        ),
      ),
    );
  }
}
