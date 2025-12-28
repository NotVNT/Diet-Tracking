import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/user_data_entity.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/user_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/repositories/scanned_food_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/get_barcode_product_info.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/save_scanned_food.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/scan_barcode_from_camera_frame.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/scan_barcode_from_image.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/entities/barcode_model.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/barcode/barcode_state.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_api_service.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_scanner_service.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';
import 'package:camera/camera.dart';

class FakeScannedFoodRepository implements ScannedFoodRepository {
  final List<ScannedFoodEntity> saved = [];

  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {
    saved.add(food);
  }
}

class FakeUserRepository implements UserRepository {
  UserDataEntity? current;

  @override
  Future<UserDataEntity?> getCurrentUserData() async => current;

  @override
  Future<bool> isUserAuthenticated() async => true;

  @override
  Future<String?> getCurrentUserId() async => 'u';

  @override
  Future<NutritionCalculation?> getNutritionPlan() async => null;

  @override
  Future<List<Map<String, dynamic>>> getRecentFoodRecords() async => const [];
}

class FakeBarcodeApiService extends BarcodeApiService {
  BarcodeProduct? scanBarcodeResult;
  Object? scanBarcodeError;

  BarcodeProduct? productInfoResult;
  Object? productInfoError;

  @override
  Future<BarcodeProduct> scanBarcode(String imagePath) async {
    final e = scanBarcodeError;
    if (e != null) throw e;

    final r = scanBarcodeResult;
    if (r == null) throw Exception('no result');
    return r;
  }

  @override
  Future<BarcodeProduct> getProductInfo(
    String barcodeValue, {
    Map<String, dynamic>? userData,
  }) async {
    final e = productInfoError;
    if (e != null) throw e;

    final r = productInfoResult;
    if (r == null) throw Exception('no result');
    return r;
  }
}

class FakeBarcodeScannerService implements IBarcodeScannerService {
  @override
  Future<List<BarcodeModel>> scanBarcodeFromImage(String imagePath) async => const [];

  @override
  Future<BarcodeModel?> scanBarcodeFromCameraImage(CameraImage image) async => null;

  @override
  void dispose() {}
}

void main() {
  BarcodeProduct sampleProduct({
    String barcode = '123',
    String? name = 'Chips',
    String? brands = 'BrandX',
    double? calories = 250,
    double? protein = 3,
    double? carbs = 30,
    double? fat = 12,
    String? ingredientsText = 'Potatoes, salt',
  }) {
    return BarcodeProduct(
      barcode: barcode,
      productName: name,
      brands: brands,
      calories: calories,
      protein: protein,
      carbohydrates: carbs,
      fat: fat,
      ingredientsText: ingredientsText,
      imageUrl: 'https://example.com/img.jpg',
    );
  }

  group('BarcodeBloc', () {
    test('BarcodeScanFromImageRequested emits uploading then resolved', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService()..scanBarcodeResult = sampleProduct();
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BarcodeUploading>(),
          predicate<BarcodeState>(
            (s) => s is BarcodeResolved && s.imagePath == '/tmp/barcode.jpg' && s.product.barcode == '123',
            'BarcodeResolved with imagePath',
          ),
        ]),
      );

      bloc.add(const BarcodeScanFromImageRequested('/tmp/barcode.jpg'));
      await states;
    });

    test('BarcodeScanFromImageRequested emits error when API throws', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService()..scanBarcodeError = Exception('fail');
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BarcodeUploading>(),
          isA<BarcodeError>(),
        ]),
      );

      bloc.add(const BarcodeScanFromImageRequested('/tmp/barcode.jpg'));
      await states;
    });

    test('BarcodeSelected emits uploading then resolved via GetBarcodeProductInfo', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService()..productInfoResult = sampleProduct(barcode: '999');
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BarcodeUploading>(),
          predicate<BarcodeState>(
            (s) => s is BarcodeResolved && s.product.barcode == '999' && s.imagePath == '/tmp/img.jpg',
            'BarcodeResolved with product',
          ),
        ]),
      );

      bloc.add(const BarcodeSelected('999', imagePath: '/tmp/img.jpg'));
      await states;
    });

    test('GetBarcodeProductInfoRequested emits uploading then BarcodeProductInfoRetrieved', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService()..productInfoResult = sampleProduct(barcode: '555');
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BarcodeUploading>(),
          predicate<BarcodeState>(
            (s) => s is BarcodeProductInfoRetrieved && s.product.barcode == '555' && s.imagePath == '/tmp/p.jpg',
            'BarcodeProductInfoRetrieved',
          ),
        ]),
      );

      bloc.add(const GetBarcodeProductInfoRequested('555', imagePath: '/tmp/p.jpg'));
      await states;
    });

    test('BuildBarcodeDescriptionRequested emits BarcodeDescriptionBuilt', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService();
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final product = sampleProduct(ingredientsText: 'Potatoes');

      final states = expectLater(
        bloc.stream,
        emits(
          predicate<BarcodeState>(
            (s) =>
                s is BarcodeDescriptionBuilt &&
                s.description.contains('Calories') &&
                s.description.contains('Protein') &&
                s.description.contains('Ingredients') &&
                s.product.barcode == product.barcode,
            'BarcodeDescriptionBuilt with macro lines',
          ),
        ),
      );

      bloc.add(BuildBarcodeDescriptionRequested(product));
      await states;
    });

    test('SaveBarcodeProductRequested emits uploading, saved success, then resolved and persists entity', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService();
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final product = sampleProduct(barcode: 'abc', name: 'Cookie', brands: 'Yum');

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<BarcodeUploading>(),
          predicate<BarcodeState>((s) => s is BarcodeSavedSuccess && s.message.contains('Scanned'), 'BarcodeSavedSuccess'),
          predicate<BarcodeState>((s) => s is BarcodeResolved && s.product.barcode == 'abc', 'BarcodeResolved'),
        ]),
      );

      bloc.add(SaveBarcodeProductRequested(product, imagePath: '/tmp/cap.jpg'));
      await states;

      expect(repo.saved, isNotEmpty);
      final saved = repo.saved.single;
      expect(saved.scanType, ScanType.barcode);
      expect(saved.imagePath, '/tmp/cap.jpg');
      expect(saved.barcode, 'abc');
      expect(saved.foodName, contains('Cookie'));
    });

    test('BarcodeResetRequested emits BarcodeInitial', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);

      final api = FakeBarcodeApiService();
      final userRepo = FakeUserRepository();
      final getInfo = GetBarcodeProductInfo(api, userRepo);

      final scannerService = FakeBarcodeScannerService();
      final scanFromImage = ScanBarcodeFromImage(scannerService);
      final scanFromFrame = ScanBarcodeFromCameraFrame(scannerService);

      final bloc = BarcodeBloc(
        scanBarcodeFromImage: scanFromImage,
        scanBarcodeFromCameraFrame: scanFromFrame,
        getBarcodeProductInfo: getInfo,
        saveScannedFood: save,
        barcodeApiService: api,
      );
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emits(isA<BarcodeInitial>()),
      );

      bloc.add(const BarcodeResetRequested());
      await states;
    });
  });
}
