import 'package:flutter/material.dart';
import '../../models/scanner_action_config.dart';
import '../modes/barcode_mode.dart';
import '../modes/scan_food_mode.dart';

class ScannerPreview extends StatelessWidget {
  final ScannerActionType action;
  final String overlayText;
  final String barcodeHint;
  final TextStyle overlayTextStyle;
  final Widget? cameraPreview;
  final Widget? barcodeControlsOverlay;
  final bool isRealTimeScanning;

  const ScannerPreview({
    super.key,
    required this.action,
    required this.overlayText,
    required this.barcodeHint,
    required this.overlayTextStyle,
    this.cameraPreview,
    this.barcodeControlsOverlay,
    this.isRealTimeScanning = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: _buildModeView());
  }

  Widget _buildModeView() {
    switch (action) {
      case ScannerActionType.food:
        return ScanFoodModeView(
          overlayText: overlayText,
          overlayTextStyle: overlayTextStyle,
          cameraPreview: cameraPreview,
        );
      case ScannerActionType.barcode:
        return BarcodeModeView(
          bottomHint: barcodeHint,
          hintStyle: overlayTextStyle,
          cameraPreview: cameraPreview,
          controlsOverlay: barcodeControlsOverlay,
          isScanning: isRealTimeScanning,
        );
      case ScannerActionType.gallery:
        return ScanFoodModeView(
          overlayText: overlayText,
          overlayTextStyle: overlayTextStyle,
          cameraPreview: cameraPreview,
        );
    }
  }
}
