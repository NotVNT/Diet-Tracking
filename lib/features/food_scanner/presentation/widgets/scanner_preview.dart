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
  final Key? barcodeScannerKey;

  const ScannerPreview({
    super.key,
    required this.action,
    required this.overlayTextStyle,
    this.cameraPreview,
    this.isRealTimeScanning = false,
    this.onBarcodeDetected,
    this.barcodeScannerKey,
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
            : MobileBarcodeScannerView(
                key: barcodeScannerKey,
                onBarcodeDetected: onBarcodeDetected!,
              );
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
