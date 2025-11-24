import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../../presentation/widgets/food_scanner_page_widget/barcode_scanner_port.dart';

/// Use case: scan a barcode from a real-time camera frame
class ScanBarcodeFromCameraFrame {
  final IBarcodeScannerService _barcodeScannerService;

  ScanBarcodeFromCameraFrame(this._barcodeScannerService);

  /// Returns the first detected barcode or null if none detected
  Future<Barcode?> call(CameraImage image) async {
    return _barcodeScannerService.scanBarcodeFromCameraImage(image);
  }
}

