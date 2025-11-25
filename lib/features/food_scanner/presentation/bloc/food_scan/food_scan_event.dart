

/// Events for FoodScanBloc (clean, single-responsibility)
abstract class FoodScanEvent {
  const FoodScanEvent();
}

/// Trigger food scan workflow for a given local image path.
class FoodScanRequested extends FoodScanEvent {
  final String imagePath;

  const FoodScanRequested({required this.imagePath});
}

/// Save image event
class SaveImageEvent extends FoodScanEvent {
  final String imagePath;

  const SaveImageEvent({required this.imagePath});
}

/// Call food recognition API event
class CallFoodRecognitionAPIEvent extends FoodScanEvent {
  final String imagePath;

  const CallFoodRecognitionAPIEvent({required this.imagePath});
}

/// Build description event
class BuildDescriptionEvent extends FoodScanEvent {
  final String? foodName;
  final double? calories;
  final String? recognitionDescription;

  const BuildDescriptionEvent({
    this.foodName,
    this.calories,
    this.recognitionDescription,
  });
}

/// Save scanned food event
class SaveScannedFoodEvent extends FoodScanEvent {
  final String imagePath;
  final String? foodName;
  final double? calories;
  final String? description;

  const SaveScannedFoodEvent({
    required this.imagePath,
    this.foodName,
    this.calories,
    this.description,
  });
}

