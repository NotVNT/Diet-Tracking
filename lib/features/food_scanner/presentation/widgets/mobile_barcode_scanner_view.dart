import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Simple MobileScanner wrapper used in Barcode mode.
/// Emits the first detected barcode value via [onBarcodeDetected] and then pauses.
class MobileBarcodeScannerView extends StatefulWidget {
  final ValueChanged<String> onBarcodeDetected;

  const MobileBarcodeScannerView({super.key, required this.onBarcodeDetected});

  @override
  State<MobileBarcodeScannerView> createState() => MobileBarcodeScannerViewState();
}

class MobileBarcodeScannerViewState extends State<MobileBarcodeScannerView> {
  late final MobileScannerController _controller;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
      formats: BarcodeFormat.values, // detect all supported formats
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;

    // Find the first non-empty value
    for (final code in codes) {
      final value = code.displayValue ?? code.rawValue;
      if (value != null && value.isNotEmpty) {
        _handled = true;
        // Pause the camera to avoid multiple detections
        try {
          await _controller.stop();
        } catch (_) {}
        if (!mounted) return;
        widget.onBarcodeDetected(value);
        break;
      }
    }
  }

  Future<void> restartScanning() async {
    _handled = false;
    try {
      await _controller.start();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
    );
  }
}

