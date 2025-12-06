import 'package:get_it/get_it.dart';
import '../domain/repositories/scanned_food_repository.dart';
import '../data/repositories/scanned_food_repository_impl.dart';
import '../services/food_recognition_service.dart';
import '../services/barcode_scanner_service.dart' as barcode_service;
import '../services/barcode_api_service.dart';
import '../services/camera_permission_service.dart';
import '../domain/usecases/save_scanned_food.dart';
import '../domain/usecases/request_camera_permission.dart';
import '../domain/usecases/scan_barcode_from_image.dart';
import '../domain/usecases/scan_barcode_from_camera_frame.dart';
import '../domain/usecases/get_barcode_product_info.dart';
import '../presentation/bloc/food_scan/food_scan_bloc.dart';
import '../presentation/bloc/barcode/barcode_bloc.dart';
import '../presentation/bloc/camera/camera_bloc.dart' as cam;
import '../presentation/bloc/camera/camera_event.dart' as cam_event;
import '../../../database/auth_service.dart';
import '../../chat_bot_view_home/data/datasources/firestore_datasource.dart';
import '../../chat_bot_view_home/data/repositories/user_repository_impl.dart';
import '../../chat_bot_view_home/domain/repositories/user_repository.dart';

/// Feature-scoped service locator for the Food Scanner module.
/// Use FoodScannerLocator.I to resolve registered services.
class FoodScannerLocator {
  FoodScannerLocator._();
  static final GetIt I = GetIt.asNewInstance();
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Setup default registrations. You can pass overrides for testing.
  static Future<void> setup({
    ScannedFoodRepository? scannedFoodRepository,
        barcode_service.IBarcodeScannerService? barcodeScannerService,
    BarcodeApiService? barcodeApiService,
    FoodRecognitionService? foodRecognitionService,
    RequestCameraPermission? requestCameraPermission,
    bool initializeCameraOnCreate = true,
  }) async {
    if (_initialized) return;

    // Repository
    I.registerLazySingleton<ScannedFoodRepository>(
      () => scannedFoodRepository ?? ScannedFoodRepositoryImpl(),
    );

    // Services
    I.registerLazySingleton<FoodRecognitionService>(
      () => foodRecognitionService ?? FoodRecognitionService(),
    );
        I.registerLazySingleton<barcode_service.IBarcodeScannerService>(
      () => barcodeScannerService ?? barcode_service.BarcodeScannerService(),
    );
    I.registerLazySingleton<BarcodeApiService>(
      () => barcodeApiService ?? BarcodeApiService(),
    );
    I.registerLazySingleton<AuthService>(() => AuthService());
    I.registerLazySingleton<FirestoreDatasource>(() => FirestoreDatasource());
    I.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(I<FirestoreDatasource>(), I<AuthService>()),
    );

    // Use cases
    I.registerLazySingleton<SaveScannedFood>(
      () => SaveScannedFood(I<ScannedFoodRepository>()),
    );
    I.registerLazySingleton<RequestCameraPermission>(
      () => requestCameraPermission ?? RequestCameraPermission(CameraPermissionService()),
    );
    I.registerLazySingleton<ScanBarcodeFromImage>(
      () => ScanBarcodeFromImage(I<barcode_service.IBarcodeScannerService>()),
    );
    I.registerLazySingleton<ScanBarcodeFromCameraFrame>(
      () => ScanBarcodeFromCameraFrame(I<barcode_service.IBarcodeScannerService>()),
    );
    I.registerLazySingleton<GetBarcodeProductInfo>(
      () => GetBarcodeProductInfo(I<BarcodeApiService>(), I<UserRepository>()),
    );

    // Blocs (factories so each page can have its own instance)
    I.registerFactory<FoodScanBloc>(
      () => FoodScanBloc(
        saveScannedFood: I<SaveScannedFood>(),
        foodRecognitionService: I<FoodRecognitionService>(),
      ),
    );
    I.registerFactory<BarcodeBloc>(
      () => BarcodeBloc(
        scanBarcodeFromImage: I<ScanBarcodeFromImage>(),
        scanBarcodeFromCameraFrame: I<ScanBarcodeFromCameraFrame>(),
        getBarcodeProductInfo: I<GetBarcodeProductInfo>(),
        saveScannedFood: I<SaveScannedFood>(),
        barcodeApiService: I<BarcodeApiService>(),
      ),
    );
    I.registerFactory<cam.CameraBloc>(
      () => cam.CameraBloc(requestPermission: I<RequestCameraPermission>())
        ..add(const cam_event.InitializeCamera()),
    );

    _initialized = true;
  }

  static Future<void> reset() async {
    _initialized = false;
    await I.reset();
  }
}

