/// Entity representing a scanned food item (image or barcode)
class ScannedFoodEntity {
  final String id;
  final String imagePath;
  final ScanType scanType;
  final DateTime scanDate;
  final bool isProcessed;

  const ScannedFoodEntity({
    required this.id,
    required this.imagePath,
    required this.scanType,
    required this.scanDate,
    this.isProcessed = false,
  });
}

/// Type of scan performed
enum ScanType {
  food,
  barcode,
  gallery,
}
