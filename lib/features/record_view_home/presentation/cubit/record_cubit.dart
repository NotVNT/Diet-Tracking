import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_food_record_usecase.dart';
import '../../domain/usecases/get_food_records_usecase.dart';
import '../../domain/usecases/delete_food_record_usecase.dart';
import '../../domain/entities/food_record_entity.dart';
import 'record_state.dart';

class RecordCubit extends Cubit<RecordState> {
  final SaveFoodRecordUseCase _saveFoodRecordUseCase;
  final GetFoodRecordsUseCase _getFoodRecordsUseCase;
  final DeleteFoodRecordUseCase _deleteFoodRecordUseCase;

  List<FoodRecordEntity> _allRecords = [];

  RecordCubit(
    this._saveFoodRecordUseCase,
    this._getFoodRecordsUseCase,
    this._deleteFoodRecordUseCase,
  ) : super(RecordInitial());

  Future<void> saveFoodRecord(
    String foodName,
    double calories, {
    String? reason,
    String? nutritionDetails,
  }) async {
    try {
      // Only emit loading if not already loading
      if (state is! RecordLoading) {
        emit(RecordLoading());
      }
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
      // Only emit loading if not already showing data
      if (state is! RecordListLoaded) {
        emit(RecordLoading());
      }
      final records = await _getFoodRecordsUseCase.call();
      _allRecords = records;
      emit(RecordListLoaded(records));
    } catch (e) {
      emit(RecordError('Lỗi khi tải danh sách món ăn: ${e.toString()}'));
    }
  }

  Future<void> deleteFoodRecord(String id) async {
    try {
      await _deleteFoodRecordUseCase.call(id);

      // Optimistically update the UI by removing the item from the local list
      final updatedRecords = _allRecords
          .where((record) => record.id != id)
          .toList();
      _allRecords = updatedRecords;

      // Emit the new state to update the UI immediately
      emit(RecordListLoaded(updatedRecords));
    } catch (e) {
      emit(RecordError('Lỗi khi xóa món ăn: ${e.toString()}'));
      // If deletion fails, reload the list to ensure data consistency
      await loadFoodRecords();
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
