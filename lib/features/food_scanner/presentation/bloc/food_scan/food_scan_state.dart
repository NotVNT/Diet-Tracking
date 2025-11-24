/// States for FoodScanBloc (clean, single-responsibility)
abstract class FoodScanState {
  const FoodScanState();
}

class FoodScanInitial extends FoodScanState {
  const FoodScanInitial();
}

class FoodScanUploading extends FoodScanState {
  const FoodScanUploading();
}

class FoodScanSuccess extends FoodScanState {
  final String message;
  const FoodScanSuccess(this.message);
}

class FoodScanError extends FoodScanState {
  final String message;
  const FoodScanError(this.message);
}

/// Image saved state
class ImageSavedState extends FoodScanState {
  final String imagePath;
  const ImageSavedState({required this.imagePath});
}

/// Food recognition API called state
class FoodRecognitionAPICalledState extends FoodScanState {
  final String? foodName;
  final double? calories;
  final String? description;

  const FoodRecognitionAPICalledState({
    this.foodName,
    this.calories,
    this.description,
  });
}

/// Description built state
class DescriptionBuiltState extends FoodScanState {
  final String description;
  const DescriptionBuiltState({required this.description});
}

