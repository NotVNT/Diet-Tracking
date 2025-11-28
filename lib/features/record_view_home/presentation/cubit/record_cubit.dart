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

  // Filters
  String _searchQuery = '';
  String? _calorieRange; // format: "min-max"

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
      await loadFoodRecords();
    } catch (e) {
      emit(RecordError('Lỗi khi ghi nhận món ăn: ${e.toString()}'));
    }
  }

  Future<void> loadFoodRecords() async {
    try {
      if (state is! RecordListLoaded) {
        emit(RecordLoading());
      }
      final records = await _getFoodRecordsUseCase.call();
      _allRecords = records;
      _emitFiltered();
    } catch (e) {
      emit(RecordError('Lỗi khi tải danh sách món ăn: ${e.toString()}'));
    }
  }

  Future<void> deleteFoodRecord(String id) async {
    try {
      await _deleteFoodRecordUseCase.call(id);
      _allRecords = _allRecords.where((record) => record.id != id).toList();
      _emitFiltered();
    } catch (e) {
      emit(RecordError('Lỗi khi xóa món ăn: ${e.toString()}'));
      await loadFoodRecords();
    }
  }

  // PUBLIC FILTER API
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _emitFiltered();
  }

  void filterRecordsByCalories(String? calorieRange) {
    _calorieRange = calorieRange;
    _emitFiltered();
  }

  void resetState() {
    emit(RecordInitial());
  }

  // INTERNAL
  void _emitFiltered() {
    final filtered = _applyFilters();
    emit(RecordListLoaded(_allRecords, filteredRecords: filtered));
  }

  List<FoodRecordEntity> _applyFilters() {
    Iterable<FoodRecordEntity> result = _allRecords;

    // Apply calorie filter if present
    if (_calorieRange != null) {
      final parts = _calorieRange!.split('-');
      if (parts.length == 2) {
        final minCalories = double.tryParse(parts[0]);
        final maxCalories = double.tryParse(parts[1]);
        if (minCalories != null && maxCalories != null) {
          result = result.where(
            (r) => r.calories >= minCalories && r.calories <= maxCalories,
          );
        }
      }
    }

    // Apply search query (case-insensitive)
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((r) => r.foodName.toLowerCase().contains(q));
    }

    return result.toList();
  }
}
