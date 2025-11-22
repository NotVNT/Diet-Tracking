/// Simple food recognition service interface and default stub implementation.
///
/// You can replace the stub with a real on-device model or call your API.
class FoodRecognitionResult {
  final String name;
  final double? calories;
  final String? description;

  FoodRecognitionResult({
    required this.name,
    this.calories,
    this.description,
  });
}

class FoodRecognitionService {
  /// Recognize food from an image path. Return null if not recognized.
  Future<FoodRecognitionResult?> recognizeFood(String imagePath) async {
    // TODO: Integrate your real AI food recognition here (on-device or API)
    // For now, return null to indicate no recognition.
    return null;
  }
}

