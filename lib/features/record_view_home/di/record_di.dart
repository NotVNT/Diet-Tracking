import '../../../database/local_storage_service.dart';
import '../data/repositories/food_record_repository_impl.dart';
import '../domain/repositories/food_record_repository.dart';
import '../domain/usecases/get_food_records_usecase.dart';
import '../domain/usecases/save_food_record_usecase.dart';
import '../domain/usecases/delete_food_record_usecase.dart';
import '../presentation/cubit/record_cubit.dart';

class RecordDI {
  static FoodRecordRepository _getFoodRecordRepository() {
    return FoodRecordRepositoryImpl(LocalStorageService());
  }

  static SaveFoodRecordUseCase _getSaveFoodRecordUseCase() {
    return SaveFoodRecordUseCase(_getFoodRecordRepository());
  }

  static GetFoodRecordsUseCase _getGetFoodRecordsUseCase() {
    return GetFoodRecordsUseCase(_getFoodRecordRepository());
  }

  static DeleteFoodRecordUseCase _getDeleteFoodRecordUseCase() {
    return DeleteFoodRecordUseCase(_getFoodRecordRepository());
  }

  static RecordCubit getRecordCubit() {
    return RecordCubit(
      _getSaveFoodRecordUseCase(),
      _getGetFoodRecordsUseCase(),
      _getDeleteFoodRecordUseCase(),
    );
  }
}
