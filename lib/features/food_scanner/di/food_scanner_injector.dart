import '../presentation/bloc/food_scan/food_scan_bloc.dart';
import '../presentation/bloc/barcode/barcode_bloc.dart';
import '../presentation/bloc/camera/camera_bloc.dart' as cam;
import '../presentation/bloc/camera/camera_event.dart' as cam_event;
import '../data/repositories/scanned_food_repository_impl.dart';
import '../domain/repositories/scanned_food_repository.dart';
import '../services/food_recognition_service.dart';
import '../services/barcode_scanner_service.dart' as barcode_service;
import '../services/barcode_api_service.dart';
import '../services/camera_permission_service.dart';
import '../domain/usecases/save_scanned_food.dart';
import '../domain/usecases/request_camera_permission.dart';
import '../domain/usecases/scan_barcode_from_image.dart';
import '../domain/usecases/scan_barcode_from_camera_frame.dart';
import '../../chat_bot_view_home/data/repositories/user_repository_impl.dart';
import '../../../database/auth_service.dart';
import '../../chat_bot_view_home/data/datasources/firestore_datasource.dart';
import '../domain/usecases/get_barcode_product_info.dart';

class FoodScannerDependencies {
  final FoodScanBloc foodScanBloc;
  final BarcodeBloc barcodeBloc;
  final cam.CameraBloc cameraBloc;
  final barcode_service.IBarcodeScannerService barcodeScannerService;

  const FoodScannerDependencies({
    required this.foodScanBloc,
    required this.barcodeBloc,
    required this.cameraBloc,
    required this.barcodeScannerService,
  });
}

/// Simple module injector for Food Scanner feature.
/// Allows overriding dependencies in tests or other environments.
class FoodScannerInjector {
  final ScannedFoodRepository? _scannedFoodRepository;
  final SaveScannedFood? _saveScannedFood;
  final FoodRecognitionService? _foodRecognitionService;
  final RequestCameraPermission? _requestCameraPermission;
  final barcode_service.IBarcodeScannerService? _barcodeScannerService;
  final BarcodeApiService? _barcodeApiService;
  final ScanBarcodeFromImage? _scanBarcodeFromImage;
  final GetBarcodeProductInfo? _getBarcodeProductInfo;
  final bool _initializeCameraOnCreate;
  // Optional prebuilt blocs for tests or advanced composition
  final FoodScanBloc? _prebuiltFoodScanBloc;
  final BarcodeBloc? _prebuiltBarcodeBloc;
  final cam.CameraBloc? _prebuiltCameraBloc;

  const FoodScannerInjector({
    ScannedFoodRepository? scannedFoodRepository,
    SaveScannedFood? saveScannedFood,
    FoodRecognitionService? foodRecognitionService,
    RequestCameraPermission? requestCameraPermission,
        barcode_service.IBarcodeScannerService? barcodeScannerService,
    BarcodeApiService? barcodeApiService,
    ScanBarcodeFromImage? scanBarcodeFromImage,
    GetBarcodeProductInfo? getBarcodeProductInfo,
    bool initializeCameraOnCreate = true,
    FoodScanBloc? prebuiltFoodScanBloc,
    BarcodeBloc? prebuiltBarcodeBloc,
    cam.CameraBloc? prebuiltCameraBloc,
  })  : _scannedFoodRepository = scannedFoodRepository,
        _saveScannedFood = saveScannedFood,
        _foodRecognitionService = foodRecognitionService,
        _requestCameraPermission = requestCameraPermission,
        _barcodeScannerService = barcodeScannerService,
        _barcodeApiService = barcodeApiService,
        _scanBarcodeFromImage = scanBarcodeFromImage,
        _getBarcodeProductInfo = getBarcodeProductInfo,
        _initializeCameraOnCreate = initializeCameraOnCreate,
        _prebuiltFoodScanBloc = prebuiltFoodScanBloc,
        _prebuiltBarcodeBloc = prebuiltBarcodeBloc,
        _prebuiltCameraBloc = prebuiltCameraBloc;

  FoodScannerDependencies create() {
    // Repository and use cases
    final repo = _scannedFoodRepository ?? ScannedFoodRepositoryImpl();
    final saveScannedFood = _saveScannedFood ?? SaveScannedFood(repo);

    // Services
    final foodRecognition = _foodRecognitionService ?? FoodRecognitionService();
    final barcodeScannerService =
        _barcodeScannerService ?? barcode_service.BarcodeScannerService();
    final apiService = _barcodeApiService ?? BarcodeApiService();

    // Use cases for barcode path
    final scanBarcodeFromImage =
        _scanBarcodeFromImage ?? ScanBarcodeFromImage(barcodeScannerService);
    final scanBarcodeFromCameraFrame =
        ScanBarcodeFromCameraFrame(barcodeScannerService);

    // Avoid constructing Firebase-backed dependencies when the use case is overridden.
    // This keeps widget tests hermetic while preserving production behavior.
    final GetBarcodeProductInfo getProductInfo;
    if (_getBarcodeProductInfo != null) {
      getProductInfo = _getBarcodeProductInfo;
    } else {
      final firestoreDatasource = FirestoreDatasource();
      final authService = AuthService();
      final userRepository = UserRepositoryImpl(firestoreDatasource, authService);
      getProductInfo = GetBarcodeProductInfo(apiService, userRepository);
    }

    // Blocs
    final foodScanBloc = _prebuiltFoodScanBloc ?? FoodScanBloc(
      saveScannedFood: saveScannedFood,
      foodRecognitionService: foodRecognition,
    );

    final barcodeBloc = _prebuiltBarcodeBloc ?? BarcodeBloc(
      scanBarcodeFromImage: scanBarcodeFromImage,
      scanBarcodeFromCameraFrame: scanBarcodeFromCameraFrame,
      getBarcodeProductInfo: getProductInfo,
      saveScannedFood: saveScannedFood,
      barcodeApiService: apiService,
    );

    final requestPermission =
        _requestCameraPermission ?? RequestCameraPermission(CameraPermissionService());
    final cameraBloc = _prebuiltCameraBloc ?? cam.CameraBloc(requestPermission: requestPermission);
    if (_prebuiltCameraBloc == null && _initializeCameraOnCreate) {
      cameraBloc.add(const cam_event.InitializeCamera());
    }

    return FoodScannerDependencies(
      foodScanBloc: foodScanBloc,
      barcodeBloc: barcodeBloc,
      cameraBloc: cameraBloc,
      barcodeScannerService: barcodeScannerService,
    );
  }
}

