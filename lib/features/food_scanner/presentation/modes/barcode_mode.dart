import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../widgets/animated_scanner_background.dart';

/// View rendered while scanning barcode with a smaller frame.
class BarcodeModeView extends StatelessWidget {
  final String bottomHint;
  final TextStyle hintStyle;
  final Widget? cameraPreview;
  final Widget? controlsOverlay;
  final bool isScanning;

  const BarcodeModeView({
    super.key,
    required this.bottomHint,
    required this.hintStyle,
    this.cameraPreview,
    this.controlsOverlay,
    this.isScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                  border: Border.all(
                    color: isScanning ? Colors.green : Colors.white,
                    width: 3,
                  ),
                ),
              ),
            ),
            if (isScanning)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Đang quét mã vạch...',
                        style: hintStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            // Removed black wrap, controls overlay, and bottom hint message
          ],
        );
      },
    );
  }
}
