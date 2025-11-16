import '../../../../database/local_storage_service.dart';

/// Local data source for profile operations (SharedPreferences)
class ProfileLocalDataSource {
  final LocalStorageService _localStorage;

  ProfileLocalDataSource({LocalStorageService? localStorage})
      : _localStorage = localStorage ?? LocalStorageService();

  /// Clear all local data
  Future<void> clearAllLocalData() async {
    await _localStorage.clearAllFoodRecords();
    await _localStorage.clearGuestData();
  }
}
