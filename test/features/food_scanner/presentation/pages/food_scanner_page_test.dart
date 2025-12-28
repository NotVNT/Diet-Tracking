import 'package:camera/camera.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/user_data_entity.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/user_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import 'package:diet_tracking_project/features/food_scanner/di/food_scanner_injector.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/entities/barcode_model.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/repositories/scanned_food_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/get_barcode_product_info.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/pages/food_scanner_page.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/scanner_bottom_overlay.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/widgets/scanner_help_sheet.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_api_service.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_scanner_service.dart';
import 'package:diet_tracking_project/features/food_scanner/services/camera_permission_service.dart';
import 'package:diet_tracking_project/features/food_scanner/services/food_recognition_service.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class FakeScannedFoodRepository implements ScannedFoodRepository {
  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {}
}

class FakeBarcodeScannerService implements IBarcodeScannerService {
  @override
  void dispose() {}

  @override
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath) async => const [];

  @override
  Future<BarcodeModel?> scanBarcodeFromCameraImage(CameraImage image) async => null;
}

class FakeBarcodeApiService implements BarcodeApiService {
  @override
  Future<bool> checkConnection() async => true;

  @override
  Future<BarcodeProduct> getProductInfo(
    String barcodeValue, {
    Map<String, dynamic>? userData,
  }) async {
    return BarcodeProduct(barcode: barcodeValue, productName: 'P');
  }

  @override
  Future<BarcodeProduct> scanBarcode(String imagePath) async {
    return BarcodeProduct(barcode: 'x', productName: 'P');
  }
}

class FakeUserRepository implements UserRepository {
  @override
  Future<UserDataEntity?> getCurrentUserData() async => null;

  @override
  Future<String?> getCurrentUserId() async => null;

  @override
  Future<List<Map<String, dynamic>>> getRecentFoodRecords() async => const [];

  @override
  Future<NutritionCalculation?> getNutritionPlan() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUserAuthenticated() async => false;
}

class FakeGetBarcodeProductInfo extends GetBarcodeProductInfo {
  FakeGetBarcodeProductInfo() : super(FakeBarcodeApiService(), FakeUserRepository());
}

class FakeFoodRecognitionService implements FoodRecognitionService {
  @override
  Future<FoodRecognitionResult?> recognizeFood(String imagePath) async => null;
}

class FakeCameraPermissionService implements CameraPermissionService {
  @override
  Future<bool> isCameraPermissionGranted() async => false;

  @override
  Map<String, bool> getSessionState() => const {
        'cameraPermissionGrantedInSession': false,
        'cameraPermissionDeniedInSession': false,
      };

  @override
  Future<ph.PermissionStatus> getCameraPermissionStatus() async => ph.PermissionStatus.denied;

  @override
  Future<bool> openAppSettings() async => false;

  @override
  Future<bool> requestCameraPermission() async => false;

  @override
  Future<ph.PermissionStatus> requestCameraPermissionStatus() async => ph.PermissionStatus.denied;

  @override
  void resetSessionState() {}
}

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}

void main() {
  testWidgets('FoodScannerPage builds (food mode) without initializing camera', (tester) async {
    final injector = FoodScannerInjector(
      initializeCameraOnCreate: false,
      scannedFoodRepository: FakeScannedFoodRepository(),
      barcodeScannerService: FakeBarcodeScannerService(),
      barcodeApiService: FakeBarcodeApiService(),
      foodRecognitionService: FakeFoodRecognitionService(),
      requestCameraPermission: null,
      getBarcodeProductInfo: FakeGetBarcodeProductInfo(),
    );

    await tester.pumpWidget(_wrap(FoodScannerPage(injector: injector)));
    await tester.pump();

    expect(find.byType(ScannerBottomOverlay), findsOneWidget);

    // Help icon exists; opening it shows the help sheet.
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    expect(find.byType(ScannerHelpSheet), findsOneWidget);
  });
}
