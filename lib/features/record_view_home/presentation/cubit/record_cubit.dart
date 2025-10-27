import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_food_record_usecase.dart';
import '../../domain/usecases/get_food_records_usecase.dart';
import '../../domain/usecases/delete_food_record_usecase.dart';
import '../../domain/usecases/sync_food_records_usecase.dart';
import '../../domain/entities/food_record_entity.dart';
import 'record_state.dart';

class RecordCubit extends Cubit<RecordState> {
  final SaveFoodRecordUseCase _saveFoodRecordUseCase;
  final GetFoodRecordsUseCase _getFoodRecordsUseCase;
  final DeleteFoodRecordUseCase _deleteFoodRecordUseCase;
  final SyncFoodRecordsUseCase _syncFoodRecordsUseCase;

  List<FoodRecordEntity> _allRecords = [];

  RecordCubit(
    this._saveFoodRecordUseCase,
    this._getFoodRecordsUseCase,
    this._deleteFoodRecordUseCase,
    this._syncFoodRecordsUseCase,
  ) : super(RecordInitial());

  Future<void> saveFoodRecord(
    String foodName,
    double calories, {
    String? reason,
    String? nutritionDetails,
  }) async {
    try {
      emit(RecordLoading());
      await _saveFoodRecordUseCase.call(
        foodName,
        calories,
        reason: reason,
        nutritionDetails: nutritionDetails,
      );
      emit(const RecordSuccess('Món ăn đã được ghi nhận thành công!'));
      // Tự động load lại danh sách sau khi lưu
      await loadFoodRecords();
    } catch (e) {
      emit(RecordError('Lỗi khi ghi nhận món ăn: ${e.toString()}'));
    }
  }

  Future<void> loadFoodRecords() async {
    try {
      emit(RecordLoading());
      // Đồng bộ dữ liệu từ Firebase trước khi load
      await _syncFoodRecordsUseCase.call();
      final records = await _getFoodRecordsUseCase.call();
      _allRecords = records;
      emit(RecordListLoaded(records));
    } catch (e) {
      emit(RecordError('Lỗi khi tải danh sách món ăn: ${e.toString()}'));
    }
  }

  Future<void> deleteFoodRecord(String id) async {
    try {
      emit(RecordLoading());
      await _deleteFoodRecordUseCase.call(id);
      emit(const RecordSuccess('Món ăn đã được xóa thành công!'));
      // Tự động load lại danh sách sau khi xóa
      await loadFoodRecords();
    } catch (e) {
      emit(RecordError('Lỗi khi xóa món ăn: ${e.toString()}'));
    }
  }

  void filterRecordsByCalories(String? calorieRange) {
    if (calorieRange == null) {
      // Show all records when no filter is selected
      emit(RecordListLoaded(_allRecords));
      return;
    }

    // Parse the calorie range
    final parts = calorieRange.split('-');
    if (parts.length != 2) return;

    final minCalories = double.tryParse(parts[0]);
    final maxCalories = double.tryParse(parts[1]);

    if (minCalories == null || maxCalories == null) return;

    // Filter records based on calorie range
    final filteredRecords = _allRecords.where((record) {
      return record.calories >= minCalories && record.calories <= maxCalories;
    }).toList();

    emit(RecordListLoaded(_allRecords, filteredRecords: filteredRecords));
  }

  void resetState() {
    emit(RecordInitial());
  }
}
