import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/domain/entities/barcode_model.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/scan_barcode_from_camera_frame.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_scanner_service.dart';

class FakeBarcodeScannerService implements IBarcodeScannerService {
  CameraImage? lastImage;
  BarcodeModel? response;

  @override
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath) async {
    throw UnimplementedError();
  }

  @override
  Future<BarcodeModel?> scanBarcodeFromCameraImage(CameraImage image) async {
    lastImage = image;
    return response;
  }

  @override
  void dispose() {}
}

class DummyCameraImage extends Fake implements CameraImage {}

void main() {
  group('ScanBarcodeFromCameraFrame', () {
    test('delegates to IBarcodeScannerService', () async {
      final service = FakeBarcodeScannerService();
      final usecase = ScanBarcodeFromCameraFrame(service);
      final image = DummyCameraImage();

      final expected = BarcodeModel(
        rawValue: '456',
        displayValue: '456',
        format: BarcodeFormat.qrCode,
        valueType: BarcodeValueType.text,
      );

      service.response = expected;

      final result = await usecase(image);

      expect(result, same(expected));
      expect(service.lastImage, same(image));
    });

    test('can return null (no barcode)', () async {
      final service = FakeBarcodeScannerService();
      final usecase = ScanBarcodeFromCameraFrame(service);
      final image = DummyCameraImage();

      service.response = null;

      final result = await usecase(image);

      expect(result, isNull);
      expect(service.lastImage, same(image));
    });
  });
}
