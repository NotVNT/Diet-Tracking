import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/scan_barcode_from_image.dart';
import '../../../domain/usecases/scan_barcode_from_camera_frame.dart';
import '../../../domain/usecases/get_barcode_product_info.dart';
import '../../../domain/usecases/save_scanned_food.dart';
import '../../../domain/entities/scanned_food_entity.dart';
import '../../../data/models/food_scanner_models.dart';
import '../../../services/barcode_api_service.dart';
import 'barcode_event.dart';
import 'barcode_state.dart';

/// BarcodeBloc: Single responsibility - handle barcode scanning flows and product save
/// - Scan barcode from still image
/// - Scan barcode from real-time camera frame (emit value only)
/// - Get product info from barcode value
/// - Build barcode description
/// - Save barcode product
class BarcodeBloc extends Bloc<BarcodeEvent, BarcodeState> {
  final ScanBarcodeFromImage scanBarcodeFromImage;
  final ScanBarcodeFromCameraFrame scanBarcodeFromCameraFrame;
  final GetBarcodeProductInfo getBarcodeProductInfo;
  final SaveScannedFood saveScannedFood;
  final BarcodeApiService barcodeApiService;

  BarcodeBloc({
    required this.scanBarcodeFromImage,
    required this.scanBarcodeFromCameraFrame,
    required this.getBarcodeProductInfo,
    required this.saveScannedFood,
    required this.barcodeApiService,
  }) : super(const BarcodeInitial()) {
    on<BarcodeScanFromImageRequested>(_onScanFromImageRequested);
    on<BarcodeScanFromCameraFrameRequested>(_onScanFromCameraFrameRequested);
    on<BarcodeSelected>(_onBarcodeSelected);
    on<BarcodeDetectedAndImageCaptured>(_onBarcodeDetectedAndImageCaptured);
    on<GetBarcodeProductInfoRequested>(_onGetProductInfo);
    on<BuildBarcodeDescriptionRequested>(_onBuildDescription);
    on<SaveBarcodeProductRequested>(_onSaveProduct);
    on<BarcodeResetRequested>(_onResetStateRequested);
  }

  Future<void> _onScanFromImageRequested(
    BarcodeScanFromImageRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeUploading());
    try {
      final product = await barcodeApiService.scanBarcode(event.imagePath);
      emit(BarcodeResolved(product, imagePath: event.imagePath));
    } catch (e) {
      emit(const BarcodeError('Error scanning barcode from image'));
    }
  }

  Future<void> _onScanFromCameraFrameRequested(
    BarcodeScanFromCameraFrameRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    try {
      final barcode = await scanBarcodeFromCameraFrame(event.image);
      if (barcode == null) return;
      final value = barcode.displayValue ?? barcode.rawValue ?? '';
      if (value.isEmpty) return;
      emit(BarcodeValueDetected(value));
    } catch (_) {
      // swallow errors for real-time scanning to avoid UI flickers
    }
  }

  Future<void> _onBarcodeDetectedAndImageCaptured(
    BarcodeDetectedAndImageCaptured event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeUploading());
    final barcodeValue = event.barcodeValue;
    try {
      final product = await getBarcodeProductInfo(barcodeValue);
      emit(BarcodeResolved(product, imagePath: event.imagePath));
    } catch (e) {
      emit(const BarcodeError('Error retrieving barcode details'));
    }
  }

  Future<void> _onBarcodeSelected(
    BarcodeSelected event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeUploading());
    final barcodeValue = event.barcodeValue;
    try {
      final product = await getBarcodeProductInfo(barcodeValue);
      emit(BarcodeResolved(product, imagePath: event.imagePath));
    } catch (e) {
      emit(const BarcodeError('Error retrieving barcode details'));
    }
  }

  /// Get barcode product info
  Future<void> _onGetProductInfo(
    GetBarcodeProductInfoRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeUploading());
    try {
      final product = await getBarcodeProductInfo(event.barcodeValue);
      emit(BarcodeProductInfoRetrieved(product, imagePath: event.imagePath));
    } catch (e) {
      emit(const BarcodeError('Could not retrieve product information'));
    }
  }

  /// Build barcode description
  Future<void> _onBuildDescription(
    BuildBarcodeDescriptionRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    try {
      final product = event.product;

      final description = _buildDescription(product);

      emit(
        BarcodeDescriptionBuilt(
          description: description.trim(),
          product: product,
        ),
      );
    } catch (e) {
      emit(const BarcodeError('Could not build description'));
    }
  }

  /// Save barcode product
  Future<void> _onSaveProduct(
    SaveBarcodeProductRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeUploading());
    try {
      final product = event.product;

      final foodName = _buildFoodName(product);
      final description = _buildDescription(product);

      await saveScannedFood(
        imagePath: event.imagePath ?? '',
        scanType: ScanType.barcode,
        foodName: foodName,
        calories: product.calories,
        description: description.trim(),
        protein: product.protein,
        carbs: product.carbohydrates,
        fat: product.fat,
        barcode: product.barcode,
      );

      emit(BarcodeSavedSuccess('Scanned: $foodName'));
      emit(BarcodeResolved(product, imagePath: event.imagePath));
    } catch (e) {
      emit(const BarcodeError('Error saving product'));
    }
  }

  Future<void> _onResetStateRequested(
    BarcodeResetRequested event,
    Emitter<BarcodeState> emit,
  ) async {
    emit(const BarcodeInitial());
  }

  String _buildFoodName(BarcodeProduct product) {
    String foodName = product.productName ?? 'Product ${product.barcode}';
    if (product.brands != null && product.brands!.isNotEmpty) {
      foodName = '${product.productName ?? "Product"} - ${product.brands}';
    }
    return foodName;
  }

  String _buildDescription(BarcodeProduct product) {
    String description = '';
    if (product.calories != null) {
      description +=
          '🔥 Calories: ${product.calories!.toStringAsFixed(0)} kcal\n';
    }
    if (product.protein != null) {
      description += '🥩 Protein: ${product.protein!.toStringAsFixed(1)}g\n';
    }
    if (product.carbohydrates != null) {
      description +=
          '🍚 Carbs: ${product.carbohydrates!.toStringAsFixed(1)}g\n';
    }
    if (product.fat != null) {
      description += '🧈 Fat: ${product.fat!.toStringAsFixed(1)}g\n';
    }
    if (product.ingredientsText != null &&
        product.ingredientsText!.isNotEmpty) {
      description += '\n📝 Ingredients: ${product.ingredientsText}';
    }
    return description;
  }
}
