import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/food_scanner_models.dart';
import '../../domain/entities/scanned_food_entity.dart';
import '../../domain/repositories/scanned_food_repository.dart';
import '../../services/barcode_scanner_service.dart' as barcode_service;
import '../../services/barcode_api_service.dart';
import '../../domain/usecases/scan_barcode_from_image.dart';
import '../../domain/usecases/request_camera_permission.dart';
import '../../domain/usecases/save_scanned_food.dart';
import '../../domain/usecases/get_barcode_product_info.dart';
import 'food_scanner_event.dart';
import 'food_scanner_state.dart';

class FoodScannerBloc extends Bloc<FoodScannerEvent, FoodScannerState> {
  final ScannedFoodRepository scannedFoodRepository;
  final barcode_service.BarcodeScannerService barcodeScannerService;
  final BarcodeApiService barcodeApiService;
  final ScanBarcodeFromImage scanBarcodeFromImageUseCase;
  final RequestCameraPermission requestCameraPermissionUseCase;
  final SaveScannedFood saveScannedFoodUseCase;
  final GetBarcodeProductInfo getBarcodeProductInfoUseCase;

  CameraController? _cameraController;
  ActionSelectedState _actionState = ActionSelectedState(
    selectedAction: ScannerActionType.food,
  );
  UploadingState _uploadingState = UploadingState(isUploading: false);
  CameraInitializingState _cameraInitState = CameraInitializingState(
    isInitializing: false,
  );
  RealTimeScanningState _realTimeScanState = RealTimeScanningState(
    isScanning: false,
  );

  FoodScannerBloc({
    required this.scannedFoodRepository,
    required this.barcodeScannerService,
    required this.barcodeApiService,
    required this.scanBarcodeFromImageUseCase,
    required this.requestCameraPermissionUseCase,
    required this.saveScannedFoodUseCase,
    required this.getBarcodeProductInfoUseCase,
  }) : super(const FoodScannerInitial()) {
    on<InitializeCameraEvent>(_onInitializeCamera);
    on<ActionSelectedEvent>(_onActionSelected);
    on<CapturePhotoEvent>(_onCapturePhoto);
    on<SaveScannedFoodEvent>(_onSaveScannedFood);
    on<ScanBarcodeFromImageEvent>(_onScanBarcodeFromImage);
    on<HandleBarcodeSelectedEvent>(_onHandleBarcodeSelected);
    on<StartRealTimeScanningEvent>(_onStartRealTimeScanning);
    on<StopRealTimeScanningEvent>(_onStopRealTimeScanning);
    on<ProcessCameraImageEvent>(_onProcessCameraImage);
    on<BarcodeDetectedEvent>(_onBarcodeDetected);
    on<SaveBarcodeProductEvent>(_onSaveBarcodeProduct);
  }

  Future<void> _onInitializeCamera(
    InitializeCameraEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_cameraInitState.isInitializing) return;
    emit(CameraInitializingState(isInitializing: true));

    final previousController = _cameraController;
    if (previousController != null) {
      await previousController.dispose();
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        emit(
          CameraErrorState(
            errorMessage: 'Không tìm thấy camera trên thiết bị.',
          ),
        );
        return;
      }

      final CameraDescription backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await controller.initialize();
      _cameraController = controller;
      emit(CameraReadyState(controller: controller));

      if (_actionState.selectedAction == ScannerActionType.barcode) {
        add(StartRealTimeScanningEvent());
      }
    } on CameraException catch (e) {
      emit(CameraErrorState(errorMessage: e.description ?? e.code));
    } catch (e) {
      emit(CameraErrorState(errorMessage: e.toString()));
    } finally {
      emit(CameraInitializingState(isInitializing: false));
    }
  }

  Future<void> _onActionSelected(
    ActionSelectedEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    _actionState = ActionSelectedState(selectedAction: event.actionType);
    emit(_actionState);

    if (event.actionType == ScannerActionType.barcode) {
      add(StartRealTimeScanningEvent());
    } else if (_realTimeScanState.isScanning) {
      add(StopRealTimeScanningEvent());
    }
  }

  Future<void> _onCapturePhoto(
    CapturePhotoEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_uploadingState.isUploading) return;

    try {
      if (event.scanType == ScanType.gallery) {
        // Mở thư viện chọn ảnh
        final picker = ImagePicker();
        final XFile? picked = await picker.pickImage(
          source: ImageSource.gallery,
        );
        if (picked == null) return;
        add(ScanBarcodeFromImageEvent(imagePath: picked.path));
        return;
      }

      // Mặc định: chụp ảnh từ camera
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        emit(ScanErrorState(message: event.placeholderMessage));
        return;
      }
      final XFile photo = await _cameraController!.takePicture();
      add(
        SaveScannedFoodEvent(imagePath: photo.path, scanType: event.scanType),
      );
    } on CameraException catch (_) {
      emit(ScanErrorState(message: event.placeholderMessage));
    } catch (_) {
      emit(ScanErrorState(message: event.placeholderMessage));
    }
  }

  Future<void> _onSaveScannedFood(
    SaveScannedFoodEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_uploadingState.isUploading) return;
    emit(UploadingState(isUploading: true));

    try {
      await saveScannedFoodUseCase(
        imagePath: event.imagePath,
        scanType: event.scanType,
        foodName: event.foodName,
        calories: event.calories,
        description: event.description,
      );
      emit(ScanSuccessState(message: 'Đã lưu ảnh thành công'));
    } catch (_) {
      emit(
        ScanErrorState(
          message: 'Không thể tải ảnh lên Cloudinary. Vui lòng thử lại.',
        ),
      );
    } finally {
      emit(UploadingState(isUploading: false));
    }
  }

  Future<void> _onScanBarcodeFromImage(
    ScanBarcodeFromImageEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_uploadingState.isUploading) return;
    emit(UploadingState(isUploading: true));

    try {
      final barcodes = await scanBarcodeFromImageUseCase(event.imagePath);
      if (barcodes.isEmpty) {
        add(
          SaveScannedFoodEvent(
            imagePath: event.imagePath,
            scanType: ScanType.gallery,
          ),
        );
        emit(NoBarcodeFoundState(imagePath: event.imagePath));
      } else {
        // Lấy barcode đầu tiên rồi tra cứu sản phẩm từ server
        final first = barcodes.first;
        final value = first.displayValue ?? first.rawValue ?? '';
        if (value.isEmpty) {
          add(
            SaveScannedFoodEvent(
              imagePath: event.imagePath,
              scanType: ScanType.gallery,
            ),
          );
          emit(NoBarcodeFoundState(imagePath: event.imagePath));
        } else {
          try {
            final product = await getBarcodeProductInfoUseCase(value);
            add(
              SaveBarcodeProductEvent(
                product: product,
                imagePath: event.imagePath,
              ),
            );
          } catch (e) {
            await saveScannedFoodUseCase(
              imagePath: '',
              scanType: ScanType.barcode,
              foodName: 'Barcode: $value',
              calories: null,
              description:
                  'Mã vạch: $value\n\nKhông tìm thấy thông tin chi tiết từ OpenFoodFacts',
            );
            emit(
              ScanSuccessState(
                message:
                    'Đã lưu mã: $value (Không tìm thấy thông tin chi tiết)',
              ),
            );
          }
        }
      }
    } catch (e) {
      add(
        SaveScannedFoodEvent(
          imagePath: event.imagePath,
          scanType: ScanType.gallery,
        ),
      );
      emit(ScanErrorState(message: 'Đã lưu ảnh'));
    } finally {
      emit(UploadingState(isUploading: false));
    }
  }

  Future<void> _onHandleBarcodeSelected(
    HandleBarcodeSelectedEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    final barcodeValue =
        event.barcode.displayValue ?? event.barcode.rawValue ?? '';
    emit(UploadingState(isUploading: true));

    try {
      try {
        final product = await getBarcodeProductInfoUseCase(barcodeValue);
        add(
          SaveBarcodeProductEvent(product: product, imagePath: event.imagePath),
        );
      } catch (e) {
        await saveScannedFoodUseCase(
          imagePath: '',
          scanType: ScanType.barcode,
          foodName: 'Barcode: $barcodeValue',
          calories: null,
          description:
              'Mã vạch: $barcodeValue\n\nKhông tìm thấy thông tin chi tiết từ OpenFoodFacts',
        );
        emit(
          ScanSuccessState(
            message: 'Đã lưu mã: $barcodeValue (Không tìm thấy chi tiết)',
          ),
        );
      }
    } finally {
      emit(UploadingState(isUploading: false));
    }
  }

  Future<void> _onStartRealTimeScanning(
    StartRealTimeScanningEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    _realTimeScanState = RealTimeScanningState(
      isScanning: true,
      lastDetectedBarcode: null,
    );
    emit(_realTimeScanState);

    _cameraController!.startImageStream((CameraImage image) {
      add(ProcessCameraImageEvent(image: image));
    });
  }

  Future<void> _onStopRealTimeScanning(
    StopRealTimeScanningEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      _cameraController!.stopImageStream();
    }

    _realTimeScanState = RealTimeScanningState(
      isScanning: false,
      lastDetectedBarcode: null,
    );
    emit(_realTimeScanState);
  }

  Future<void> _onProcessCameraImage(
    ProcessCameraImageEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    if (!_realTimeScanState.isScanning || _uploadingState.isUploading) return;

    try {
      final barcode = await barcodeScannerService.scanBarcodeFromCameraImage(
        event.image,
      );
      if (barcode != null) {
        final barcodeValue = barcode.displayValue ?? barcode.rawValue ?? '';

        if (barcodeValue == _realTimeScanState.lastDetectedBarcode) {
          final now = DateTime.now();
          if (_realTimeScanState.lastBarcodeDetectionTime != null &&
              now
                      .difference(_realTimeScanState.lastBarcodeDetectionTime!)
                      .inSeconds <
                  3) {
            return;
          }
        }

        _realTimeScanState = RealTimeScanningState(
          isScanning: _realTimeScanState.isScanning,
          lastDetectedBarcode: barcodeValue,
          lastBarcodeDetectionTime: DateTime.now(),
        );
        emit(_realTimeScanState);
        add(BarcodeDetectedEvent(barcode: barcode));
      }
    } catch (e) {
      // Ignore errors during real-time scanning
    }
  }

  Future<void> _onBarcodeDetected(
    BarcodeDetectedEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    add(StopRealTimeScanningEvent());
    emit(UploadingState(isUploading: true));

    try {
      final controller = _cameraController;
      if (controller == null || !controller.value.isInitialized) {
        throw Exception('Camera chưa sẵn sàng');
      }

      final XFile photo = await controller.takePicture();
      final barcodeValue =
          event.barcode.displayValue ?? event.barcode.rawValue ?? '';

      try {
        final product = await getBarcodeProductInfoUseCase(barcodeValue);
        add(SaveBarcodeProductEvent(product: product, imagePath: photo.path));
      } catch (e) {
        await saveScannedFoodUseCase(
          imagePath: '',
          scanType: ScanType.barcode,
          foodName: 'Barcode: $barcodeValue',
          calories: null,
          description:
              'Mã vạch: $barcodeValue\n\nKhông tìm thấy thông tin chi tiết từ OpenFoodFacts',
        );
        emit(
          ScanSuccessState(
            message:
                'Đã lưu mã: $barcodeValue (Không tìm thấy thông tin chi tiết)',
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      emit(ScanErrorState(message: 'Lỗi khi quét barcode'));
      add(StartRealTimeScanningEvent());
    } finally {
      emit(UploadingState(isUploading: false));
    }
  }

  Future<void> _onSaveBarcodeProduct(
    SaveBarcodeProductEvent event,
    Emitter<FoodScannerState> emit,
  ) async {
    try {
      String foodName =
          event.product.productName ?? 'Sản phẩm ${event.product.barcode}';
      if (event.product.brands != null && event.product.brands!.isNotEmpty) {
        foodName =
            '${event.product.productName ?? "Sản phẩm"} - ${event.product.brands}';
      }

      String description = 'Barcode: ${event.product.barcode}\n\n';

      if (event.product.calories != null) {
        description +=
            '🔥 Calories: ${event.product.calories!.toStringAsFixed(0)} kcal\n';
      }
      if (event.product.protein != null) {
        description +=
            '🥩 Protein: ${event.product.protein!.toStringAsFixed(1)}g\n';
      }
      if (event.product.carbohydrates != null) {
        description +=
            '🍚 Carbs: ${event.product.carbohydrates!.toStringAsFixed(1)}g\n';
      }
      if (event.product.fat != null) {
        description += '🧈 Fat: ${event.product.fat!.toStringAsFixed(1)}g\n';
      }
      if (event.product.ingredientsText != null &&
          event.product.ingredientsText!.isNotEmpty) {
        description += '\n📝 Nguyên liệu: ${event.product.ingredientsText}';
      }

      await saveScannedFoodUseCase(
        imagePath: '',
        scanType: ScanType.barcode,
        foodName: foodName,
        calories: event.product.calories,
        description: description.trim(),
      );

      emit(ScanSuccessState(message: 'Đã quét: $foodName'));
    } catch (e) {
      emit(ScanErrorState(message: 'Lỗi khi lưu sản phẩm'));
    }
  }

  @override
  Future<void> close() {
    _cameraController?.dispose();
    barcodeScannerService.dispose();
    return super.close();
  }
}
