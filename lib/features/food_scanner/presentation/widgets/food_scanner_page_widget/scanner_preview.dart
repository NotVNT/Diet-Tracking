import 'package:flutter/material.dart';
import '../../../data/models/food_scanner_models.dart';
import 'scanner_widgets.dart';

class ScannerPreview extends StatelessWidget {
  final ScannerActionType action;
  final TextStyle overlayTextStyle;
  final Widget? cameraPreview;
  final bool isRealTimeScanning;

  const ScannerPreview({
    super.key,
    required this.action,
    required this.overlayTextStyle,
    this.cameraPreview,
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
          cameraPreview: cameraPreview,
        );
      case ScannerActionType.barcode:
        return BarcodeModeView(
          hintStyle: overlayTextStyle,
          cameraPreview: cameraPreview,
          isScanning: isRealTimeScanning,
        );
      case ScannerActionType.gallery:
        return ScanFoodModeView(
          cameraPreview: cameraPreview,
        );
    }
  }
}
