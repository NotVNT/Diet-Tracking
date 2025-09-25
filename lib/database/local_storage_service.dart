import 'package:shared_preferences/shared_preferences.dart';

/// Lưu trữ cục bộ thông tin người dùng chưa đăng nhập
/// Bao gồm: mục tiêu (goal), chiều cao, cân nặng, tuổi, giới tính
class LocalStorageService {
  static const String _keyGoal = 'guest_goal';
  static const String _keyHeight = 'guest_height_cm';
  static const String _keyWeight = 'guest_weight_kg';
  static const String _keyAge = 'guest_age';
  static const String _keyGender = 'guest_gender';

  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  Future<void> saveGuestData({
    String? goal,
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
  }) async {
    final prefs = await _prefs;
    if (goal != null) await prefs.setString(_keyGoal, goal);
    if (heightCm != null) await prefs.setDouble(_keyHeight, heightCm);
    if (weightKg != null) await prefs.setDouble(_keyWeight, weightKg);
    if (age != null) await prefs.setInt(_keyAge, age);
    if (gender != null) await prefs.setString(_keyGender, gender);
  }

  Future<Map<String, dynamic>> readGuestData() async {
    final prefs = await _prefs;
    return {
      'goal': prefs.getString(_keyGoal),
      'heightCm': prefs.getDouble(_keyHeight),
      'weightKg': prefs.getDouble(_keyWeight),
      'age': prefs.getInt(_keyAge),
      'gender': prefs.getString(_keyGender),
    };
  }

  Future<bool> hasGuestData() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyGoal) ||
        prefs.containsKey(_keyHeight) ||
        prefs.containsKey(_keyWeight) ||
        prefs.containsKey(_keyAge) ||
        prefs.containsKey(_keyGender);
  }

  Future<void> clearGuestData() async {
    final prefs = await _prefs;
    await prefs.remove(_keyGoal);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyWeight);
    await prefs.remove(_keyAge);
    await prefs.remove(_keyGender);
  }
}
