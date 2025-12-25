import 'package:flutter/material.dart';
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
  DateTimeRange? _dateRange; // inclusive range

  RecordCubit(
    this._saveFoodRecordUseCase,
    this._getFoodRecordsUseCase,
    this._deleteFoodRecordUseCase,
  ) : super(RecordInitial());

  Future<void> saveFoodRecord(
    String foodName,
    double calories, {
    double? protein,
    double? carbs,
    double? fat,
    String? reason,
    String? nutritionDetails,
    RecordType recordType = RecordType.manual,
  }) async {
    try {
      if (state is! RecordLoading) {
        emit(RecordLoading());
      }
      await _saveFoodRecordUseCase.call(
        foodName,
        calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        reason: reason,
        nutritionDetails: nutritionDetails,
        recordType: recordType,
      );
      emit(const RecordSuccess('Món ăn đã được ghi nhận thành công!'));
      await loadFoodRecords();
    } catch (e) {
      emit(RecordError('Lỗi khi ghi nhận món ăn: ${e.toString()}'));
    }
  }

  Future<void> saveMultipleFoodRecords(List<FoodRecordEntity> records) async {
    try {
      if (state is! RecordLoading) {
        emit(RecordLoading());
      }
      for (final record in records) {
        await _saveFoodRecordUseCase.call(
          record.foodName,
          record.calories,
          protein: record.protein,
          carbs: record.carbs,
          fat: record.fat,
          reason: record.reason,
          nutritionDetails: record.nutritionDetails,
          recordType: record.recordType,
        );
      }
      emit(RecordSuccess('Đã thêm ${records.length} món vào danh sách'));
      await loadFoodRecords();
    } catch (e) {
      emit(RecordError('Lỗi khi ghi nhận các món ăn: ${e.toString()}'));
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

  // GETTERS for UI
  String? get calorieRange => _calorieRange;
  DateTimeRange? get dateRange => _dateRange;
  bool get hasActiveFilters => _calorieRange != null || _dateRange != null;

  // PUBLIC FILTER API
  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    _emitFiltered();
  }

  void filterRecordsByCalories(String? calorieRange) {
    _calorieRange = calorieRange;
    _emitFiltered();
  }

  void setDateRangeFilter(DateTimeRange? range) {
    _dateRange = range;
    _emitFiltered();
  }

  // Apply both filters in one emission to avoid intermediate states
  void setFilters({String? calorieRange, DateTimeRange? dateRange}) {
    _calorieRange = calorieRange;
    _dateRange = dateRange;
    _emitFiltered();
  }

  void clearFilters() {
    _calorieRange = null;
    _dateRange = null;
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

    // Apply date range filter (inclusive)
    if (_dateRange != null) {
      final start = _dateRange!.start;
      final end = _dateRange!.end;
      result = result.where((r) {
        final d = r.date.toLocal();
        // Compare dates at the day level to avoid time/timezone issues
        final recordDay = DateTime(d.year, d.month, d.day);
        final startDay = DateTime(start.year, start.month, start.day);
        final endDay = DateTime(end.year, end.month, end.day);
        return !recordDay.isBefore(startDay) && !recordDay.isAfter(endDay);
      });
    }

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
