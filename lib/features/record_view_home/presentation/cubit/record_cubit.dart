import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/save_food_record_usecase.dart';
import '../../domain/usecases/get_food_records_usecase.dart';
import '../../domain/usecases/delete_food_record_usecase.dart';
import 'record_state.dart';

class RecordCubit extends Cubit<RecordState> {
  final SaveFoodRecordUseCase _saveFoodRecordUseCase;
  final GetFoodRecordsUseCase _getFoodRecordsUseCase;
  final DeleteFoodRecordUseCase _deleteFoodRecordUseCase;

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
      final records = await _getFoodRecordsUseCase.call();
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

  void resetState() {
    emit(RecordInitial());
  }
}
