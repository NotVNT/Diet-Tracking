import '../../services/barcode_api_service.dart';
import '../../data/models/food_scanner_models.dart';
import '../../../chat_bot_view_home/domain/repositories/user_repository.dart';

/// Use case: Lấy thông tin sản phẩm từ mã barcode (OpenFoodFacts qua server Python)
class GetBarcodeProductInfo {
  final BarcodeApiService _apiService;
  final UserRepository _userRepository;

  GetBarcodeProductInfo(this._apiService, this._userRepository);

  /// Trả về BarcodeProduct nếu thành công, ném Exception nếu lỗi
  Future<BarcodeProduct> call(String barcodeValue) async {
    Map<String, dynamic>? userDataMap;
    try {
      final user = await _userRepository.getCurrentUserData();
      if (user != null) {
        userDataMap = {
          'age': user.age,
          'height': user.height,
          'weight': user.weight,
          'goalWeightKg': user.goalWeightKg,
          'disease': user.disease,
          'allergy': user.allergy,
          'goal': user.goal,
          'gender': user.gender,
        };
        // Dev log: có thể thay bằng logger nếu cần
        // ignore: avoid_print
        print('🟣 [UseCase] userData gửi tới barcode: $userDataMap');
      }
    } catch (_) {
      // Bỏ qua, không chặn request nếu không lấy được user
    }

    return _apiService.getProductInfo(barcodeValue, userData: userDataMap);
  }
}
