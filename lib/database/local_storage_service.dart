import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý dữ liệu tạm thời của người dùng guest
/// Lưu trữ thông tin onboarding trước khi đăng ký tài khoản chính thức
class LocalStorageService {
  // Private keys cho SharedPreferences
  static const String _keyGoal = 'guest_goal';
  static const String _keyHeight = 'guest_height_cm';
  static const String _keyWeight = 'guest_weight_kg';
  static const String _keyGoalWeight = 'guest_goal_weight_kg';
  static const String _keyGoalHeight = 'guest_goal_height_cm';
  static const String _keyHealth = 'guest_health';
  static const String _keyAge = 'guest_age';
  static const String _keyGender = 'guest_gender';
  static const String _keyLanguage = 'selected_language';
  static const String _keyMedical = 'guest_medical_conditions';
  static const String _keyAllergies = 'guest_allergies';

  /// Lazy initialization của SharedPreferences
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Lưu dữ liệu guest vào local storage
  /// Chỉ lưu các trường được cung cấp (không null)
  Future<void> saveGuestData({
    String? goal,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    double? goalHeightCm,
    String? health,
    List<String>? medicalConditions,
    List<String>? allergies,
    int? age,
    String? gender,
    String? language,
  }) async {
    final prefs = await _prefs;

    // Lưu từng trường nếu có giá trị
    if (goal != null) await prefs.setString(_keyGoal, goal);
    if (heightCm != null) await prefs.setDouble(_keyHeight, heightCm);
    if (weightKg != null) await prefs.setDouble(_keyWeight, weightKg);
    if (goalWeightKg != null)
      await prefs.setDouble(_keyGoalWeight, goalWeightKg);
    if (goalHeightCm != null)
      await prefs.setDouble(_keyGoalHeight, goalHeightCm);
    if (health != null) await prefs.setString(_keyHealth, health);
    if (medicalConditions != null && medicalConditions.isNotEmpty) {
      await prefs.setStringList(_keyMedical, medicalConditions);
    }
    if (allergies != null && allergies.isNotEmpty) {
      await prefs.setStringList(_keyAllergies, allergies);
    }
    if (age != null) await prefs.setInt(_keyAge, age);
    if (gender != null) await prefs.setString(_keyGender, gender);
    if (language != null) await prefs.setString(_keyLanguage, language);
  }

  /// Đọc tất cả dữ liệu guest từ local storage
  /// Trả về Map với các key tương ứng với từng trường dữ liệu
  Future<Map<String, dynamic>> readGuestData() async {
    final prefs = await _prefs;
    return {
      'goal': prefs.getString(_keyGoal),
      'heightCm': prefs.getDouble(_keyHeight),
      'weightKg': prefs.getDouble(_keyWeight),
      'goalWeightKg': prefs.getDouble(_keyGoalWeight),
      'goalHeightCm': prefs.getDouble(_keyGoalHeight),
      'health': prefs.getString(_keyHealth),
      'medicalConditions': prefs.getStringList(_keyMedical),
      'allergies': prefs.getStringList(_keyAllergies),
      'age': prefs.getInt(_keyAge),
      'gender': prefs.getString(_keyGender),
      'language': prefs.getString(_keyLanguage),
    };
  }

  /// Kiểm tra xem có dữ liệu guest nào được lưu không
  /// Trả về true nếu có ít nhất một trường dữ liệu
  Future<bool> hasGuestData() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyGoal) ||
        prefs.containsKey(_keyHeight) ||
        prefs.containsKey(_keyWeight) ||
        prefs.containsKey(_keyGoalWeight) ||
        prefs.containsKey(_keyGoalHeight) ||
        prefs.containsKey(_keyHealth) ||
        prefs.containsKey(_keyMedical) ||
        prefs.containsKey(_keyAllergies) ||
        prefs.containsKey(_keyAge) ||
        prefs.containsKey(_keyGender) ||
        prefs.containsKey(_keyLanguage);
  }

  /// Xóa tất cả dữ liệu guest khỏi local storage
  /// Được gọi sau khi đồng bộ thành công với tài khoản chính thức
  Future<void> clearGuestData() async {
    final prefs = await _prefs;

    // Xóa từng key một cách tuần tự
    await prefs.remove(_keyGoal);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyWeight);
    await prefs.remove(_keyGoalWeight);
    await prefs.remove(_keyGoalHeight);
    await prefs.remove(_keyHealth);
    await prefs.remove(_keyMedical);
    await prefs.remove(_keyAllergies);
    await prefs.remove(_keyAge);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyLanguage);
  }
}
