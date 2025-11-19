import 'package:flutter/material.dart';
import '../widgets/animated_scanner_background.dart';

/// View rendered while user scans food by taking a photo.
class ScanFoodModeView extends StatelessWidget {
  final String overlayText;
  final TextStyle overlayTextStyle;
  final Widget? cameraPreview;

  const ScanFoodModeView({
    super.key,
    required this.overlayText,
    required this.overlayTextStyle,
    this.cameraPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: cameraPreview ?? const AnimatedScannerBackground(),
        ),
      ],
    );
  }
}
