import 'package:flutter/material.dart';
import '../widgets/animated_scanner_background.dart';

/// View rendered while user scans food by taking a photo.
class ScanFoodModeView extends StatelessWidget {
  final String overlayText;
  final TextStyle overlayTextStyle;

  const ScanFoodModeView({
    super.key,
    required this.overlayText,
    required this.overlayTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AnimatedScannerBackground(),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              overlayText,
              style: overlayTextStyle,
            ),
          ),
        ),
      ],
    );
  }
}
