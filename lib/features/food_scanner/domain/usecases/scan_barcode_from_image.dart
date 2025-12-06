import '../entities/barcode_model.dart';
import '../../services/barcode_scanner_service.dart';

/// Use case để quét barcode từ ảnh
///
/// Chịu trách nhiệm cho việc:
/// - Quét barcode từ đường dẫn ảnh
/// - Trả về danh sách các barcode tìm thấy
class ScanBarcodeFromImage {
  final IBarcodeScannerService _barcodeScannerService;

  ScanBarcodeFromImage(this._barcodeScannerService);

  /// Quét barcode từ đường dẫn ảnh
  ///
  /// Tham số:
  /// - [imagePath]: Đường dẫn tới file ảnh
  ///
  /// Trả về:
  /// - Danh sách các barcode tìm thấy (có thể rỗng)
  ///
  /// Ném:
  /// - Exception nếu quét thất bại
  Future<List<BarcodeModel>> call(String imagePath) async {
    return _barcodeScannerService.scanBarcodeFromImage(imagePath);
  }
}