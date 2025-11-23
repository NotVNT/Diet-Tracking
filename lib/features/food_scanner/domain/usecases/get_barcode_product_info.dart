import '../../services/barcode_api_service.dart';
import '../../data/models/food_scanner_models.dart';

/// Use case: Lấy thông tin sản phẩm từ mã barcode (OpenFoodFacts qua server Python)
class GetBarcodeProductInfo {
  final BarcodeApiService _apiService;

  GetBarcodeProductInfo(this._apiService);

  /// Trả về BarcodeProduct nếu thành công, ném Exception nếu lỗi
  Future<BarcodeProduct> call(String barcodeValue) async {
    return _apiService.getProductInfo(barcodeValue);
  }
}
