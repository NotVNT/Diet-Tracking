import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý dữ liệu tạm thời của người dùng guest
/// Lưu trữ thông tin onboarding trước khi đăng ký tài khoản chính thức
class LocalStorageService {
  // Private keys cho SharedPreferences
  // Kept for backward-compatible clearing; not used for writes
  static const String _keyGoal = 'guest_goal';
  static const String _keyHeight = 'guest_height_cm';
  static const String _keyWeight = 'guest_weight_kg';
  static const String _keyGoalWeight = 'guest_goal_weight_kg';
  // Removed: goal height and health keys are no longer used or referenced
  static const String _keyAge = 'guest_age';
  static const String _keyGender = 'guest_gender';
  static const String _keyLanguage = 'selected_language';
  static const String _keyMedical = 'guest_medical_conditions';
  static const String _keyAllergies = 'guest_allergies';
  static const String _keyActivityLevel = 'guest_activity_level';
  static const String _keyWeightReasons = 'guest_weight_reasons';

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
    List<String>? weightReasons,
    int? age,
    String? gender,
    String? language,
    String? activityLevel,
  }) async {
    final prefs = await _prefs;

    // Lưu từng trường nếu có giá trị
    if (goal != null) {
      print('🔍 LocalStorageService: Saving goal = $goal');
      await prefs.setString(_keyGoal, goal);
    }
    if (heightCm != null) await prefs.setDouble(_keyHeight, heightCm);
    if (weightKg != null) await prefs.setDouble(_keyWeight, weightKg);
    if (goalWeightKg != null)
      await prefs.setDouble(_keyGoalWeight, goalWeightKg);
    // Do not store goalHeightCm and health anymore
    if (medicalConditions != null && medicalConditions.isNotEmpty) {
      await prefs.setStringList(_keyMedical, medicalConditions);
    }
    if (allergies != null && allergies.isNotEmpty) {
      await prefs.setStringList(_keyAllergies, allergies);
    }
    if (age != null) await prefs.setInt(_keyAge, age);
    if (gender != null) await prefs.setString(_keyGender, gender);
    if (language != null) await prefs.setString(_keyLanguage, language);
    if (activityLevel != null) {
      await prefs.setString(_keyActivityLevel, activityLevel);
    }
    if (weightReasons != null && weightReasons.isNotEmpty) {
      await prefs.setStringList(_keyWeightReasons, weightReasons);
    }
  }

  /// Đọc tất cả dữ liệu guest từ local storage
  /// Trả về Map với các key tương ứng với từng trường dữ liệu
  Future<Map<String, dynamic>> readGuestData() async {
    final prefs = await _prefs;
    final goal = prefs.getString(_keyGoal);
    print('🔍 LocalStorageService: Reading goal = $goal');
    return {
      'goal': goal,
      'heightCm': prefs.getDouble(_keyHeight),
      'weightKg': prefs.getDouble(_keyWeight),
      'goalWeightKg': prefs.getDouble(_keyGoalWeight),
      // 'goalHeightCm' and 'health' no longer stored
      'medicalConditions': prefs.getStringList(_keyMedical),
      'allergies': prefs.getStringList(_keyAllergies),
      'age': prefs.getInt(_keyAge),
      'gender': prefs.getString(_keyGender),
      'language': prefs.getString(_keyLanguage),
      'activityLevel': prefs.getString(_keyActivityLevel),
      'weightReasons': prefs.getStringList(_keyWeightReasons),
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
        // no longer checks for goalHeight and health
        prefs.containsKey(_keyMedical) ||
        prefs.containsKey(_keyAllergies) ||
        prefs.containsKey(_keyAge) ||
        prefs.containsKey(_keyGender) ||
        prefs.containsKey(_keyLanguage) ||
        prefs.containsKey(_keyActivityLevel);
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
    // No longer storing goalHeight and health
    await prefs.remove(_keyMedical);
    await prefs.remove(_keyAllergies);
    await prefs.remove(_keyAge);
    await prefs.remove(_keyGender);
    await prefs.remove(_keyLanguage);
    await prefs.remove(_keyActivityLevel);
  }

  /// Generic method to save any data with a key
  Future<void> saveData(String key, dynamic data) async {
    final prefs = await _prefs;

    if (data is String) {
      await prefs.setString(key, data);
    } else if (data is int) {
      await prefs.setInt(key, data);
    } else if (data is double) {
      await prefs.setDouble(key, data);
    } else if (data is bool) {
      await prefs.setBool(key, data);
    } else if (data is List<String>) {
      await prefs.setStringList(key, data);
    } else if (data is List) {
      // If it's a list of maps or complex items, store as JSON string
      try {
        await prefs.setString(key, jsonEncode(data));
      } catch (_) {
        // Fallback to toString if encoding fails
        await prefs.setString(key, data.toString());
      }
    } else if (data is Map) {
      // Store maps as JSON string
      await prefs.setString(key, jsonEncode(data));
    } else {
      // For other complex objects, convert to JSON string when possible
      try {
        await prefs.setString(key, jsonEncode(data));
      } catch (_) {
        await prefs.setString(key, data.toString());
      }
    }
  }

  /// Generic method to get any data by key
  Future<dynamic> getData(String key) async {
    final prefs = await _prefs;
    final value = prefs.get(key);
    if (value is String) {
      final trimmed = value.trim();
      if ((trimmed.startsWith('[') && trimmed.endsWith(']')) ||
          (trimmed.startsWith('{') && trimmed.endsWith('}'))) {
        try {
          return jsonDecode(trimmed);
        } catch (_) {
          // Not a valid JSON, return raw string
        }
      }
    }
    return value;
  }

  /// Remove data by key
  Future<void> removeData(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }

  /// Xóa tất cả dữ liệu food records của tất cả user
  /// Được gọi khi đăng xuất để tránh lộ dữ liệu
  Future<void> clearAllFoodRecords() async {
    final prefs = await _prefs;
    final allKeys = prefs.getKeys();

    // Xóa tất cả key bắt đầu với 'food_records'
    for (final key in allKeys) {
      if (key.startsWith('food_records')) {
        await prefs.remove(key);
      }
    }
  }
}
