import 'package:camera/camera.dart';
import '../../../food_scanner/data/models/food_scanner_models.dart';

/// Base state class for food scanner
abstract class FoodScannerState {
  const FoodScannerState();
}

/// Initial state
class FoodScannerInitial extends FoodScannerState {
  const FoodScannerInitial();
}

/// Camera initialization state
class CameraInitializingState extends FoodScannerState {
  final bool isInitializing;

  const CameraInitializingState({required this.isInitializing});
}

/// Camera ready state
class CameraReadyState extends FoodScannerState {
  final CameraController controller;

  const CameraReadyState({required this.controller});
}

/// Camera error state
class CameraErrorState extends FoodScannerState {
  final String errorMessage;

  const CameraErrorState({required this.errorMessage});
}

/// Action selected state
class ActionSelectedState extends FoodScannerState {
  final ScannerActionType selectedAction;

  const ActionSelectedState({required this.selectedAction});
}

/// Uploading state
class UploadingState extends FoodScannerState {
  final bool isUploading;

  const UploadingState({required this.isUploading});
}

/// Real-time scanning state
class RealTimeScanningState extends FoodScannerState {
  final bool isScanning;
  final String? lastDetectedBarcode;
  final DateTime? lastBarcodeDetectionTime;

  const RealTimeScanningState({
    required this.isScanning,
    this.lastDetectedBarcode,
    this.lastBarcodeDetectionTime,
  });
}

/// Success state
class ScanSuccessState extends FoodScannerState {
  final String message;

  const ScanSuccessState({required this.message});
}

/// Error state
class ScanErrorState extends FoodScannerState {
  final String message;

  const ScanErrorState({required this.message});
}

/// Barcode product found state
class BarcodeProductFoundState extends FoodScannerState {
  final BarcodeProduct product;
  final String imagePath;

  const BarcodeProductFoundState({
    required this.product,
    required this.imagePath,
  });
}

/// No barcode found state
class NoBarcodeFoundState extends FoodScannerState {
  final String imagePath;

  const NoBarcodeFoundState({required this.imagePath});
}
