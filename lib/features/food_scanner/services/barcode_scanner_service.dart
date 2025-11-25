import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
/// Abstraction for barcode scanning operations to enable testing and swapping impls.
abstract class IBarcodeScannerService {
  Future<List<Barcode>> scanBarcodeFromImage(String imagePath);
  Future<Barcode?> scanBarcodeFromCameraImage(CameraImage image);
  void dispose();
}

/// Service to scan barcodes from images and real-time camera frames
class BarcodeScannerService implements IBarcodeScannerService {
  final BarcodeScanner _barcodeScanner;
  bool _isProcessing = false;

  BarcodeScannerService()
      : _barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);

  /// Scan barcodes from image file path
  @override
  Future<List<Barcode>> scanBarcodeFromImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);
      return barcodes;
    } catch (e) {
      throw BarcodeScanException('Không thể quét barcode: $e');
    }
  }

  /// Scan barcodes from a File
  Future<List<Barcode>> scanBarcodeFromFile(File imageFile) async {
    return scanBarcodeFromImage(imageFile.path);
  }

  /// Scan from camera frame (real-time). Returns first found or null
  @override
  Future<Barcode?> scanBarcodeFromCameraImage(CameraImage image) async {
    if (_isProcessing) return null;

    _isProcessing = true;
    try {
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) return null;

      final barcodes = await _barcodeScanner.processImage(inputImage);
      return barcodes.isNotEmpty ? barcodes.first : null;
    } catch (e) {
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  /// Convert CameraImage to InputImage
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      final bytes = _concatenatePlanes(image.planes);

      final Size imageSize = Size(
        image.width.toDouble(),
        image.height.toDouble(),
      );

      const InputImageRotation imageRotation = InputImageRotation.rotation0deg;
      const InputImageFormat inputImageFormat = InputImageFormat.nv21;

      final planeData = image.planes.map((Plane plane) {
        return InputImageMetadata(
          size: imageSize,
          rotation: imageRotation,
          format: inputImageFormat,
          bytesPerRow: plane.bytesPerRow,
        );
      }).first;

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: planeData,
      );
    } catch (e) {
      return null;
    }
  }

  /// Concatenate plane bytes
  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = BytesBuilder();
    for (final Plane plane in planes) {
      allBytes.add(plane.bytes);
    }
    return allBytes.toBytes();
  }

  /// Release resources
  @override
  void dispose() {
    _barcodeScanner.close();
  }
}

/// Exception for barcode scanning failure
class BarcodeScanException implements Exception {
  final String message;
  BarcodeScanException(this.message);

  @override
  String toString() => message;
}
