import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

/// Abstraction for barcode scanning operations to enable testing and swapping impls.
abstract class IBarcodeScannerService {
  Future<List<Barcode>> scanBarcodeFromImage(String imagePath);
  Future<Barcode?> scanBarcodeFromCameraImage(CameraImage image);
  void dispose();
}

