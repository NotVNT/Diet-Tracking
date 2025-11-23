/// Entity representing a scanned food item (image or barcode)
class ScannedFoodEntity {
  final String? id;
  final String imagePath;
  final ScanType scanType;
  final DateTime scanDate;
  final bool isProcessed;
  final String? foodName; // Tên món ăn (từ barcode hoặc AI)
  final double? calories; // Calories (từ OpenFoodFacts)
  final String? description; // Mô tả/thông tin dinh dưỡng

  const ScannedFoodEntity({
    required this.id,
    required this.imagePath,
    required this.scanType,
    required this.scanDate,
    this.isProcessed = false,
    this.foodName,
    this.calories,
    this.description,
  });
}

/// Type of scan performed
enum ScanType { food, barcode, gallery }
