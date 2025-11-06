import '../../../../database/auth_service.dart';
import '../../../../model/nutrition_calculation_model.dart';
import '../../domain/entities/user_data_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firestore_datasource.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final FirestoreDatasource _firestoreDatasource;
  final AuthService _authService;

  UserRepositoryImpl(this._firestoreDatasource, this._authService);

  @override
  Future<UserDataEntity?> getCurrentUserData() async {
    final userDataModel = await _firestoreDatasource.getCurrentUserData();
    return userDataModel?.toEntity();
  }

  @override
  Future<bool> isUserAuthenticated() async {
    return _firestoreDatasource.isUserAuthenticated();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return _firestoreDatasource.getCurrentUserId();
  }

  @override
  Future<NutritionCalculation?> getNutritionPlan() async {
    return _authService.getNutritionPlanForCurrentUser();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentFoodRecords() async {
    final uid = await getCurrentUserId();
    if (uid == null) {
      return []; // Return empty list if no user is logged in
    }
    return _authService.getRecentFoodRecords(uid);
  }
}
