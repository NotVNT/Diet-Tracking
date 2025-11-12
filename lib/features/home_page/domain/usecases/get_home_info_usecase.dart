import '../entities/home_info.dart';
import '../repositories/home_repository.dart';

/// Use case for getting home page information
class GetHomeInfoUseCase {
  final HomeRepository repository;
  
  GetHomeInfoUseCase(this.repository);
  
  Future<HomeInfo> call() async {
    return await repository.getHomeInfo();
  }
}
