import '../../food_scanner/data/datasources/scanned_food_local_datasource.dart';
import '../../food_scanner/data/repositories/scanned_food_repository_impl.dart';
import '../../food_scanner/domain/repositories/scanned_food_repository.dart';
import '../../../services/notification_service.dart';
import '../../../services/permission_service.dart';
import '../data/datasources/home_local_datasource.dart';
import '../data/repositories/home_repository_impl.dart';
import '../domain/repositories/home_repository.dart';
import '../domain/usecases/get_home_info_usecase.dart';
import '../presentation/providers/home_provider.dart';

/// Dependency injection for home page feature
class HomeDI {
  static HomeLocalDataSource? _localDataSource;
  static HomeRepository? _repository;
  static GetHomeInfoUseCase? _getHomeInfoUseCase;
  static ScannedFoodRepository? _scannedFoodRepository;
  static PermissionService? _permissionService;
  static LocalNotificationService? _notificationService;

  static HomeLocalDataSource _getLocalDataSource() {
    _localDataSource ??= HomeLocalDataSource();
    return _localDataSource!;
  }

  static HomeRepository _getRepository() {
    _repository ??= HomeRepositoryImpl(_getLocalDataSource());
    return _repository!;
  }

  static GetHomeInfoUseCase _getGetHomeInfoUseCase() {
    _getHomeInfoUseCase ??= GetHomeInfoUseCase(_getRepository());
    return _getHomeInfoUseCase!;
  }

  static ScannedFoodRepository _getScannedFoodRepository() {
    _scannedFoodRepository ??= ScannedFoodRepositoryImpl(
      localDataSource: ScannedFoodLocalDataSource(),
    );
    return _scannedFoodRepository!;
  }

  static PermissionService _getPermissionService() {
    _permissionService ??= PermissionService();
    return _permissionService!;
  }

  static LocalNotificationService _getNotificationService() {
    _notificationService ??= LocalNotificationService();
    return _notificationService!;
  }

  static HomeProvider getHomeProvider() {
    return HomeProvider(
      getHomeInfoUseCase: _getGetHomeInfoUseCase(),
      repository: _getRepository(),
      scannedFoodRepository: _getScannedFoodRepository(),
      permissionService: _getPermissionService(),
      notificationService: _getNotificationService(),
    );
  }
}
