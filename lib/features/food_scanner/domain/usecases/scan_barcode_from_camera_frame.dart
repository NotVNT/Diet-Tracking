import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../../services/barcode_scanner_service.dart';

/// Use case: scan a barcode from a real-time camera frame
class ScanBarcodeFromCameraFrame {
  final IBarcodeScannerService _barcodeScannerService;

  ScanBarcodeFromCameraFrame(this._barcodeScannerService);

  /// Returns the first detected barcode or null if none detected
  Future<Barcode?> call(CameraImage image) async {
    return _barcodeScannerService.scanBarcodeFromCameraImage(image);
  }
}

