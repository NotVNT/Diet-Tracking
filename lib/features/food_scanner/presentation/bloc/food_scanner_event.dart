import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../../../food_scanner/data/models/food_scanner_models.dart';
import '../../domain/entities/scanned_food_entity.dart';

/// Base event class for food scanner
abstract class FoodScannerEvent {
  const FoodScannerEvent();
}

/// Initialize camera event
class InitializeCameraEvent extends FoodScannerEvent {
  const InitializeCameraEvent();
}

/// Request camera permission event
class RequestCameraPermissionEvent extends FoodScannerEvent {
  const RequestCameraPermissionEvent();
}

/// Action selected event
class ActionSelectedEvent extends FoodScannerEvent {
  final ScannerActionType actionType;

  const ActionSelectedEvent({required this.actionType});
}

/// Capture photo event
class CapturePhotoEvent extends FoodScannerEvent {
  final ScanType scanType;
  final String placeholderMessage;

  const CapturePhotoEvent({
    required this.scanType,
    required this.placeholderMessage,
  });
}

/// Save scanned food event
class SaveScannedFoodEvent extends FoodScannerEvent {
  final String imagePath;
  final ScanType scanType;
  final String? foodName;
  final double? calories;
  final String? description;

  const SaveScannedFoodEvent({
    required this.imagePath,
    required this.scanType,
    this.foodName,
    this.calories,
    this.description,
  });
}

/// Scan barcode from image event
class ScanBarcodeFromImageEvent extends FoodScannerEvent {
  final String imagePath;

  const ScanBarcodeFromImageEvent({required this.imagePath});
}

/// Show barcode result dialog event
class ShowBarcodeResultDialogEvent extends FoodScannerEvent {
  final List<Barcode> barcodes;
  final String imagePath;

  const ShowBarcodeResultDialogEvent({
    required this.barcodes,
    required this.imagePath,
  });
}

/// Handle barcode selected event
class HandleBarcodeSelectedEvent extends FoodScannerEvent {
  final Barcode barcode;
  final String imagePath;

  const HandleBarcodeSelectedEvent({
    required this.barcode,
    required this.imagePath,
  });
}

/// Start real-time scanning event
class StartRealTimeScanningEvent extends FoodScannerEvent {
  const StartRealTimeScanningEvent();
}

/// Stop real-time scanning event
class StopRealTimeScanningEvent extends FoodScannerEvent {
  const StopRealTimeScanningEvent();
}

/// Process camera image event
class ProcessCameraImageEvent extends FoodScannerEvent {
  final CameraImage image;

  const ProcessCameraImageEvent({required this.image});
}

/// Barcode detected event
class BarcodeDetectedEvent extends FoodScannerEvent {
  final Barcode barcode;

  const BarcodeDetectedEvent({required this.barcode});
}

/// Save barcode product event
class SaveBarcodeProductEvent extends FoodScannerEvent {
  final BarcodeProduct product;
  final String imagePath;

  const SaveBarcodeProductEvent({
    required this.product,
    required this.imagePath,
  });
}

/// Open gallery picker event
class OpenGalleryPickerEvent extends FoodScannerEvent {
  const OpenGalleryPickerEvent();
}

/// Pick from gallery event
class PickFromGalleryEvent extends FoodScannerEvent {
  const PickFromGalleryEvent();
}

/// Show help event
class ShowHelpEvent extends FoodScannerEvent {
  const ShowHelpEvent();
}

/// Show error message event
class ShowErrorMessageEvent extends FoodScannerEvent {
  const ShowErrorMessageEvent();
}

/// Show success message event
class ShowSuccessMessageEvent extends FoodScannerEvent {
  const ShowSuccessMessageEvent();
}

/// Show placeholder message event
class ShowPlaceholderMessageEvent extends FoodScannerEvent {
  final String message;

  const ShowPlaceholderMessageEvent({required this.message});
}

/// Get barcode product info event
class GetBarcodeProductInfoEvent extends FoodScannerEvent {
  final String barcodeValue;

  const GetBarcodeProductInfoEvent({required this.barcodeValue});
}
