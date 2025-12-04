import '../entities/scanned_food_entity.dart';
import '../repositories/scanned_food_repository.dart';

/// Use case: Lưu thông tin một lần quét (ảnh hoặc barcode) vào kho lưu trữ
class SaveScannedFood {
  final ScannedFoodRepository _repository;

  SaveScannedFood(this._repository);

  /// Lưu và trả về entity đã lưu (để thuận tiện cho việc debug/test nếu cần)
  Future<ScannedFoodEntity> call({
    required String imagePath,
    required ScanType scanType,
    bool isProcessed = false,
    String? foodName,
    double? calories,
    String? description,
  }) async {
    final entity = ScannedFoodEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      scanType: scanType,
      scanDate: DateTime.now(),
      isProcessed: isProcessed,
      foodName: foodName,
      calories: calories,
      description: description,
    );

    await _repository.saveScannedFood(entity);
    return entity;
  }
}
