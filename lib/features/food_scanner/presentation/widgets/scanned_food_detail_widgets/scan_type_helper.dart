import '../../../domain/entities/scanned_food_entity.dart';

/// Helper class for scan type related operations
class ScanTypeHelper {
  /// Get the title for the scan type
  static String getScanTypeTitle(ScanType scanType) {
    return switch (scanType) {
      ScanType.food => 'Food Photo',
      ScanType.barcode => 'Barcode Scan',
      ScanType.gallery => 'Gallery Image',
    };
  }

  /// Get the label for the scan type
  static String getScanTypeLabel(ScanType scanType) {
    return switch (scanType) {
      ScanType.food => 'Food Camera',
      ScanType.barcode => 'Barcode Scanner',
      ScanType.gallery => 'From Gallery',
    };
  }
}

