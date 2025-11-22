import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/notification_service.dart';
import '../../../../services/permission_service.dart';
import '../../../food_scanner/domain/entities/scanned_food_entity.dart';
import '../../../food_scanner/domain/repositories/scanned_food_repository.dart';
import '../../domain/entities/home_info.dart';
import '../../domain/usecases/get_home_info_usecase.dart';
import '../../domain/repositories/home_repository.dart';

/// Provider for home page state management
class HomeProvider extends ChangeNotifier {
  final GetHomeInfoUseCase getHomeInfoUseCase;
  final HomeRepository repository;
  final ScannedFoodRepository scannedFoodRepository;
  final PermissionService permissionService;
  final LocalNotificationService notificationService;

  HomeInfo _homeInfo = HomeInfo(currentIndex: 0);
  List<ScannedFoodEntity> _scannedFoods = [];
  bool _isLoading = false;
  String? _error;

  HomeInfo get homeInfo => _homeInfo;
  int get currentIndex => _homeInfo.currentIndex;
  List<ScannedFoodEntity> get scannedFoods => _scannedFoods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeProvider({
    required this.getHomeInfoUseCase,
    required this.repository,
    required this.scannedFoodRepository,
    required this.permissionService,
    required this.notificationService,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadHomeInfo();
    await loadScannedFoods();
    await ensureNotificationPermissionAndWelcome();
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

  Future<void> loadScannedFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _scannedFoods = await scannedFoodRepository.getRecentScannedFoods(limit: 6);
    } catch (e) {
      _error = 'Unable to load scanned foods: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteScannedFood(String foodId) async {
    try {
      await scannedFoodRepository.deleteScannedFood(foodId);
      await loadScannedFoods(); // Refresh the list
    } catch (e) {
      _error = 'Failed to delete food: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  Future<bool> requestCameraPermission() async {
    return await permissionService.requestCameraPermission();
  }

  Future<void> ensureNotificationPermissionAndWelcome() async {
    final prefs = await SharedPreferences.getInstance();
    const hasShownKey = 'notification_welcome_shown_v1';

    bool granted = await permissionService.isNotificationPermissionGranted();
    if (!granted) {
      granted = await permissionService.requestNotificationPermission();
      if (!granted) return; // User denied permission
    }

    final alreadyShown = prefs.getBool(hasShownKey) ?? false;
    if (!alreadyShown) {
      await notificationService.showSimpleNotification(
        title: 'Notifications',
        body: 'Diet Tracking is ready to send you notifications.',
      );
      await prefs.setBool(hasShownKey, true);
    }
  }
}
