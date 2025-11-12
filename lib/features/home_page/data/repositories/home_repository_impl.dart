import '../../domain/entities/home_info.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_datasource.dart';

/// Implementation of HomeRepository
class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;
  
  HomeRepositoryImpl(this.localDataSource);
  
  @override
  Future<HomeInfo> getHomeInfo() async {
    final currentIndex = localDataSource.getCurrentIndex();
    return HomeInfo(currentIndex: currentIndex);
  }
  
  @override
  Future<void> updateCurrentIndex(int index) async {
    localDataSource.setCurrentIndex(index);
  }
}
