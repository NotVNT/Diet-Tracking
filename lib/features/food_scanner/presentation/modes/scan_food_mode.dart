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
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final double dynamicGap = (mediaQuery.size.height * 0.12)
        .clamp(96.0, 160.0)
        .toDouble();
    return Stack(
      children: [
        Positioned.fill(
          child: cameraPreview ?? const AnimatedScannerBackground(),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.fromLTRB(16, 16, 16, dynamicGap + bottomInset),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(overlayText, style: overlayTextStyle),
          ),
        ),
      ],
    );
  }
}
