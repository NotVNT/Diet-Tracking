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
  
  static HomeProvider getHomeProvider() {
    return HomeProvider(
      getHomeInfoUseCase: _getGetHomeInfoUseCase(),
      repository: _getRepository(),
    );
  }
}
