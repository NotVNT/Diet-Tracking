import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/domain/entities/barcode_model.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/scan_barcode_from_image.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_scanner_service.dart';

class FakeBarcodeScannerService implements IBarcodeScannerService {
  String? lastImagePath;
  List<BarcodeModel> response = const [];

  @override
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath) async {
    lastImagePath = imagePath;
    return response;
  }

  @override
  Future<BarcodeModel?> scanBarcodeFromCameraImage(dynamic image) async {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}

void main() {
  group('ScanBarcodeFromImage', () {
    test('delegates to IBarcodeScannerService', () async {
      final service = FakeBarcodeScannerService();
      final usecase = ScanBarcodeFromImage(service);

      const imagePath = 'C:/tmp/foo.jpg';
      final expected = [
        BarcodeModel(
          rawValue: '123',
          displayValue: '123',
          format: BarcodeFormat.ean13,
          valueType: BarcodeValueType.product,
        ),
      ];

      service.response = expected;

      final result = await usecase(imagePath);

      expect(result, same(expected));
      expect(service.lastImagePath, imagePath);
    });
  });
}
