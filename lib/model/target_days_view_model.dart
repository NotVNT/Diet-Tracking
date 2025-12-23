import 'package:flutter/foundation.dart';

import '../database/local_storage_service.dart';
import 'nutrition_calculation_model.dart';
import '../services/nutrition_calculator_service.dart';

class TargetDaysViewModel extends ChangeNotifier {
  TargetDaysViewModel({
    LocalStorageService? localStorage,
    int initialDays = 30,
  })  : _local = localStorage ?? LocalStorageService(),
        _selectedDays = initialDays {
    load();
  }

  final LocalStorageService _local;

  bool _isLoading = true;
  String? _errorMessage;

  int _selectedDays;
  UserNutritionInfo? _userInfo;
  NutritionCalculation? _calculation;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get selectedDays => _selectedDays;
  UserNutritionInfo? get userInfo => _userInfo;
  NutritionCalculation? get calculation => _calculation;

  int? get recommendedDays {
    final info = _userInfo;
    if (info == null) return null;
    return NutritionCalculatorService.calculateRecommendedDays(userInfo: info);
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _local.readGuestData();

      final ageRaw = data['age'];
      final genderRaw = data['gender'];
      final heightRaw = data['heightCm'];
      final weightRaw = data['weightKg'];
      final goalWeightRaw = data['goalWeightKg'];
      final activityRaw = data['activityLevel'];

      final age = ageRaw is int ? ageRaw : (ageRaw is num ? ageRaw.toInt() : null);
      final gender = genderRaw is String ? genderRaw : null;
      final heightCm = heightRaw is num ? heightRaw.toDouble() : null;
      final currentWeightKg = weightRaw is num ? weightRaw.toDouble() : null;
      final targetWeightKg = goalWeightRaw is num ? goalWeightRaw.toDouble() : null;
      final activityLevel = activityRaw is String ? activityRaw : null;

      if (age == null ||
          gender == null ||
          heightCm == null ||
          currentWeightKg == null ||
          targetWeightKg == null ||
          activityLevel == null) {
        _errorMessage = 'Thiếu thông tin người dùng. Vui lòng quay lại và nhập đầy đủ.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _userInfo = UserNutritionInfo(
        age: age,
        gender: gender,
        heightCm: heightCm,
        currentWeightKg: currentWeightKg,
        targetWeightKg: targetWeightKg,
        activityLevel: activityLevel,
      );

      _recalculate();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Lỗi khi tải dữ liệu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedDays(int days) {
    if (days == _selectedDays) return;
    _selectedDays = days;
    _recalculate();
    notifyListeners();
  }

  Future<bool> persistSelection() async {
    final calc = _calculation;
    if (calc == null) return false;

    await _local.saveData('targetDays', _selectedDays);
    await _local.saveData('nutritionCalculation', calc.toJson());
    return true;
  }

  void _recalculate() {
    final info = _userInfo;
    if (info == null) return;

    _calculation = NutritionCalculatorService.calculate(
      userInfo: info,
      targetDays: _selectedDays,
    );
  }
}
