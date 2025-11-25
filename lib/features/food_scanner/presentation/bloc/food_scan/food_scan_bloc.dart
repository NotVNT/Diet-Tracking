import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/scanned_food_entity.dart';
import '../../../services/food_recognition_service.dart';
import '../../../domain/usecases/save_scanned_food.dart';
import 'food_scan_event.dart';
import 'food_scan_state.dart';

/// FoodScanBloc: Single responsibility - handle food image processing only
/// - Save image
/// - Call food recognition API/service
/// - Build description
/// - Save scanned food
/// No barcode or camera logic here.
class FoodScanBloc extends Bloc<FoodScanEvent, FoodScanState> {
  final SaveScannedFood saveScannedFood;
  final FoodRecognitionService foodRecognitionService;

  FoodScanBloc({
    required this.saveScannedFood,
    required this.foodRecognitionService,
  }) : super(const FoodScanInitial()) {
    on<FoodScanRequested>(_onFoodScanRequested);
    on<SaveImageEvent>(_onSaveImage);
    on<CallFoodRecognitionAPIEvent>(_onCallFoodRecognitionAPI);
    on<BuildDescriptionEvent>(_onBuildDescription);
    on<SaveScannedFoodEvent>(_onSaveScannedFood);
  }

  /// Handle food scan workflow
  Future<void> _onFoodScanRequested(
    FoodScanRequested event,
    Emitter<FoodScanState> emit,
  ) async {
    emit(const FoodScanUploading());
    try {
      final recognition =
          await foodRecognitionService.recognizeFood(event.imagePath);

      final String? foodName = recognition?.name;
      final double? calories = recognition?.calories;

      String description = '';
      if (recognition != null) {
        if (recognition.calories != null) {
          description +=
              '🔥 Calories: ${recognition.calories!.toStringAsFixed(0)} kcal\n';
        }
        if (recognition.description != null &&
            recognition.description!.isNotEmpty) {
          description +=
              (description.isEmpty ? '' : '\n') + recognition.description!;
        }
      }

      await saveScannedFood(
        imagePath: event.imagePath,
        scanType: ScanType.food,
        foodName: foodName,
        calories: calories,
        description: description.isEmpty ? null : description.trim(),
      );

      emit(FoodScanSuccess(
          'Food saved${foodName != null ? ': $foodName' : ''}'));
    } catch (e) {
      emit(const FoodScanError('Could not process image. Please try again.'));
    }
  }

  /// Save image
  Future<void> _onSaveImage(
    SaveImageEvent event,
    Emitter<FoodScanState> emit,
  ) async {
    try {
      emit(ImageSavedState(imagePath: event.imagePath));
    } catch (e) {
      emit(const FoodScanError('Could not save image.'));
    }
  }

  /// Call food recognition API
  Future<void> _onCallFoodRecognitionAPI(
    CallFoodRecognitionAPIEvent event,
    Emitter<FoodScanState> emit,
  ) async {
    emit(const FoodScanUploading());
    try {
      final recognition =
          await foodRecognitionService.recognizeFood(event.imagePath);

      emit(FoodRecognitionAPICalledState(
        foodName: recognition?.name,
        calories: recognition?.calories,
        description: recognition?.description,
      ));
    } catch (e) {
      emit(const FoodScanError('Could not recognize food from image.'));
    }
  }

  /// Build description from recognition data
  Future<void> _onBuildDescription(
    BuildDescriptionEvent event,
    Emitter<FoodScanState> emit,
  ) async {
    try {
      String description = '';

      if (event.calories != null) {
        description +=
            '🔥 Calories: ${event.calories!.toStringAsFixed(0)} kcal\n';
      }

      if (event.recognitionDescription != null &&
          event.recognitionDescription!.isNotEmpty) {
        description += (description.isEmpty ? '' : '\n') +
            event.recognitionDescription!;
      }

      emit(DescriptionBuiltState(
        description: description.isEmpty ? '' : description.trim(),
      ));
    } catch (e) {
      emit(const FoodScanError('Could not build description.'));
    }
  }

  /// Save scanned food
  Future<void> _onSaveScannedFood(
    SaveScannedFoodEvent event,
    Emitter<FoodScanState> emit,
  ) async {
    emit(const FoodScanUploading());
    try {
      await saveScannedFood(
        imagePath: event.imagePath,
        scanType: ScanType.food,
        foodName: event.foodName,
        calories: event.calories,
        description: event.description,
      );

      emit(FoodScanSuccess(
          'Food saved${event.foodName != null ? ': ${event.foodName}' : ''}'));
    } catch (e) {
      emit(const FoodScanError('Could not save scanned food.'));
    }
  }
}

