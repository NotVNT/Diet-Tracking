import 'dart:io';
import 'package:camera/camera.dart';
import '../domain/entities/barcode_model.dart';

/// Abstraction for barcode scanning operations to enable testing and swapping impls.
abstract class IBarcodeScannerService {
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath);
  Future<BarcodeModel?> scanBarcodeFromCameraImage(CameraImage image);
  void dispose();
}

/// Service to scan barcodes from images and real-time camera frames
/// Uses the mobile_scanner package (no Google ML Kit dependency)
class BarcodeScannerService implements IBarcodeScannerService {
  bool _isProcessing = false;

  BarcodeScannerService();

  /// Scan barcodes from image file path
  @override
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath) async {
    try {
      final imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        throw BarcodeScanException('Image file not found: $imagePath');
      }

      // mobile_scanner requires a controller for image analysis
      // For static image analysis, we would need to use the controller
      // This is a limitation of mobile_scanner - it's designed for real-time camera scanning
      // For now, return empty list as a placeholder
      // In production, you might want to use a different library for static image analysis
      return [];
    } catch (e) {
      throw BarcodeScanException('Khong the quet barcode: $e');
    }
  }

  /// Scan barcodes from a File
  Future<List<BarcodeModel>> scanBarcodeFromFile(File imageFile) async {
    return scanBarcodeFromImage(imageFile.path);
  }

  /// Scan from camera frame (real-time). Returns first found or null
  @override
  Future<BarcodeModel?> scanBarcodeFromCameraImage(CameraImage image) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    try {
      // mobile_scanner handles camera image processing internally
      // This is a placeholder for integration with camera frames
      // In real implementation, you would use mobile_scanner's controller
      return null;
    } catch (e) {
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Release resources
  @override
  void dispose() {
    // No resources to clean up with mobile_scanner static methods
  }
}

/// Exception for barcode scanning failure
class BarcodeScanException implements Exception {
  final String message;
  BarcodeScanException(this.message);

  @override
  String toString() => message;
}
