import '../../domain/entities/user_data_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/firestore_datasource.dart';

/// Implementation of UserRepository
class UserRepositoryImpl implements UserRepository {
  final FirestoreDatasource _firestoreDatasource;

  UserRepositoryImpl(this._firestoreDatasource);

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
}
