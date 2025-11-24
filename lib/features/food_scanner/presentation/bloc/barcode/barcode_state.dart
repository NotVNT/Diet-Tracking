import '../../../data/models/food_scanner_models.dart';

/// States for BarcodeBloc (clean, single-responsibility)
abstract class BarcodeState {
  const BarcodeState();
}

class BarcodeInitial extends BarcodeState {
  const BarcodeInitial();
}

class BarcodeUploading extends BarcodeState {
  const BarcodeUploading();
}

class BarcodeNoBarcodeFound extends BarcodeState {
  final String imagePath;
  const BarcodeNoBarcodeFound(this.imagePath);
}

class BarcodeResolved extends BarcodeState {
  final BarcodeProduct product;
  final String? imagePath;
  const BarcodeResolved(this.product, {this.imagePath});
}

class BarcodeSavedSuccess extends BarcodeState {
  final String message;
  const BarcodeSavedSuccess(this.message);
}

class BarcodeError extends BarcodeState {
  final String message;
  const BarcodeError(this.message);
}

/// Emitted when a barcode value is detected from a real-time camera frame.
/// UI can react by capturing a still image and dispatching BarcodeSelected.
class BarcodeValueDetected extends BarcodeState {
  final String barcodeValue;
  const BarcodeValueDetected(this.barcodeValue);
}

/// Barcode scanned from image state
class BarcodeScannedFromImage extends BarcodeState {
  final String barcodeValue;
  final String imagePath;

  const BarcodeScannedFromImage({
    required this.barcodeValue,
    required this.imagePath,
  });
}

/// Product info retrieved state
class BarcodeProductInfoRetrieved extends BarcodeState {
  final BarcodeProduct product;
  final String? imagePath;

  const BarcodeProductInfoRetrieved(
    this.product, {
    this.imagePath,
  });
}

/// Barcode description built state
class BarcodeDescriptionBuilt extends BarcodeState {
  final String description;
  final BarcodeProduct product;

  const BarcodeDescriptionBuilt({
    required this.description,
    required this.product,
  });
}
