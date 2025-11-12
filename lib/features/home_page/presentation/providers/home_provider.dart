import 'package:flutter/foundation.dart';
import '../../domain/entities/home_info.dart';
import '../../domain/usecases/get_home_info_usecase.dart';
import '../../domain/repositories/home_repository.dart';

/// Provider for home page state management
class HomeProvider extends ChangeNotifier {
  final GetHomeInfoUseCase getHomeInfoUseCase;
  final HomeRepository repository;
  
  HomeInfo _homeInfo = HomeInfo(currentIndex: 0);
  
  HomeInfo get homeInfo => _homeInfo;
  int get currentIndex => _homeInfo.currentIndex;
  
  HomeProvider({
    required this.getHomeInfoUseCase,
    required this.repository,
  }) {
    _loadHomeInfo();
  }
  
  Future<void> _loadHomeInfo() async {
    _homeInfo = await getHomeInfoUseCase();
    notifyListeners();
  }
  
  Future<void> setCurrentIndex(int index) async {
    await repository.updateCurrentIndex(index);
    _homeInfo = _homeInfo.copyWith(currentIndex: index);
    notifyListeners();
  }
}
