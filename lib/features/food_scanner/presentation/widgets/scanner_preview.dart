import 'package:flutter/material.dart';
import '../../data/models/food_scanner_models.dart';
import 'scanner_widgets.dart';
import 'mobile_barcode_scanner_view.dart';

class ScannerPreview extends StatelessWidget {
  final ScannerActionType action;
  final TextStyle overlayTextStyle;
  final Widget? cameraPreview; // Used for food/gallery modes
  final bool
  isRealTimeScanning; // Deprecated for barcode (mobile_scanner handles state)
  final ValueChanged<String>? onBarcodeDetected;

  const ScannerPreview({
    super.key,
    required this.action,
    required this.overlayTextStyle,
    this.cameraPreview,
    this.isRealTimeScanning = false,
    this.onBarcodeDetected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(child: _buildModeView());
  }

  Widget _buildModeView() {
    switch (action) {
      case ScannerActionType.food:
        return ScanFoodModeView(cameraPreview: cameraPreview);
      case ScannerActionType.barcode:
        final barcodeCamera = onBarcodeDetected == null
            ? null
            : MobileBarcodeScannerView(onBarcodeDetected: onBarcodeDetected!);
        return BarcodeModeView(
          hintStyle: overlayTextStyle,
          cameraPreview: barcodeCamera,
          isScanning: true,
        );
      case ScannerActionType.gallery:
        return ScanFoodModeView(cameraPreview: cameraPreview);
    }
  }
}
