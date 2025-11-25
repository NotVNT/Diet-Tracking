import 'package:camera/camera.dart';
import '../../../data/models/food_scanner_models.dart';

/// Events for BarcodeBloc (clean, single-responsibility)
abstract class BarcodeEvent {
  const BarcodeEvent();
}

/// Request scanning barcode(s) from a still image path
class BarcodeScanFromImageRequested extends BarcodeEvent {
  final String imagePath;
  const BarcodeScanFromImageRequested(this.imagePath);
}

/// Request scanning barcode from a real-time camera frame
class BarcodeScanFromCameraFrameRequested extends BarcodeEvent {
  final CameraImage image;
  const BarcodeScanFromCameraFrameRequested(this.image);
}

/// Barcode value has been chosen (from image results or realtime)
class BarcodeSelected extends BarcodeEvent {
  final String barcodeValue;
  final String? imagePath; // optional image used for display/trace
  const BarcodeSelected(this.barcodeValue, {this.imagePath});
}

/// Barcode was detected and a photo was captured for it
class BarcodeDetectedAndImageCaptured extends BarcodeEvent {
  final String barcodeValue;
  final String imagePath;
  const BarcodeDetectedAndImageCaptured(this.barcodeValue, this.imagePath);
}

/// Get barcode product info event
class GetBarcodeProductInfoRequested extends BarcodeEvent {
  final String barcodeValue;
  final String? imagePath;

  const GetBarcodeProductInfoRequested(
    this.barcodeValue, {
    this.imagePath,
  });
}

/// Build barcode description event
class BuildBarcodeDescriptionRequested extends BarcodeEvent {
  final BarcodeProduct product;

  const BuildBarcodeDescriptionRequested(this.product);
}

/// Save barcode product event
class SaveBarcodeProductRequested extends BarcodeEvent {
  final BarcodeProduct product;
  final String? imagePath;

  const SaveBarcodeProductRequested(
    this.product, {
    this.imagePath,
  });
}
