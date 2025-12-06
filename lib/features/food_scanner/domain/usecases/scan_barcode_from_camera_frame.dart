import 'package:camera/camera.dart';
import '../entities/barcode_model.dart';
import '../../services/barcode_scanner_service.dart';

/// Use case: scan a barcode from a real-time camera frame
class ScanBarcodeFromCameraFrame {
  final IBarcodeScannerService _barcodeScannerService;

  ScanBarcodeFromCameraFrame(this._barcodeScannerService);

  /// Returns the first detected barcode or null if none detected
  Future<BarcodeModel?> call(CameraImage image) async {
    return _barcodeScannerService.scanBarcodeFromCameraImage(image);
  }
}

