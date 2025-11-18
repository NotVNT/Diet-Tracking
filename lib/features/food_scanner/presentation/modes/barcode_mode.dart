import 'package:flutter/material.dart';
import '../widgets/animated_scanner_background.dart';

/// View rendered while scanning barcode with a smaller frame.
class BarcodeModeView extends StatelessWidget {
  final String bottomHint;
  final TextStyle hintStyle;

  const BarcodeModeView({
    super.key,
    required this.bottomHint,
    required this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            const AnimatedScannerBackground(),
            Center(
              child: Container(
                width: constraints.maxWidth * 0.65,
                height: constraints.maxHeight * 0.35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
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
                  bottomHint,
                  style: hintStyle,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
