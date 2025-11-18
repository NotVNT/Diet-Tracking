import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../widgets/animated_scanner_background.dart';

/// View rendered while scanning barcode with a smaller frame.
class BarcodeModeView extends StatelessWidget {
  final String bottomHint;
  final TextStyle hintStyle;
  final Widget? cameraPreview;

  const BarcodeModeView({
    super.key,
    required this.bottomHint,
    required this.hintStyle,
    this.cameraPreview,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bottomInset = MediaQuery.of(context).padding.bottom;
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        const double minWidth = 220;
        final double maxAllowedWidth = math.max(maxWidth - 32, minWidth);
        final double targetWidth = maxWidth * 0.75;
        final double frameWidth = targetWidth
            .clamp(minWidth, maxAllowedWidth)
            .toDouble();

        const double widthToHeightRatio = 2.4;
        const double minHeight = 110;
        final double tentativeHeight = frameWidth / widthToHeightRatio;
        final double maxAllowedHeight = math.max(maxHeight * 0.45, minHeight);
        final double frameHeight = tentativeHeight
            .clamp(minHeight, maxAllowedHeight)
            .toDouble();

        final double bottomGap = (maxHeight * 0.12)
            .clamp(96.0, 170.0)
            .toDouble();

        return Stack(
          children: [
            Positioned.fill(
              child: cameraPreview ?? const AnimatedScannerBackground(),
            ),
            Center(
              child: Container(
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin:
                    EdgeInsets.fromLTRB(16, 16, 16, bottomGap + bottomInset),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.65),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(bottomHint, style: hintStyle),
              ),
            ),
          ],
        );
      },
    );
  }
}
