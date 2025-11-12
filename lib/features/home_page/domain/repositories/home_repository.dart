import '../entities/home_info.dart';

/// Abstract repository for home page data
abstract class HomeRepository {
  /// Get current home info
  Future<HomeInfo> getHomeInfo();
  
  /// Update current page index
  Future<void> updateCurrentIndex(int index);
}
