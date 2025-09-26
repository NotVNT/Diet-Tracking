import 'package:shared_preferences/shared_preferences.dart';

/// Service để quản lý dữ liệu tạm thời của người dùng guest
/// Lưu trữ thông tin onboarding trước khi đăng ký tài khoản chính thức
class LocalStorageService {
  // Private keys cho SharedPreferences
  static const String _keyGoal = 'guest_goal';
  static const String _keyHeight = 'guest_height_cm';
  static const String _keyWeight = 'guest_weight_kg';
  static const String _keyAge = 'guest_age';
  static const String _keyGender = 'guest_gender';

  /// Lazy initialization của SharedPreferences
  Future<SharedPreferences> get _prefs async =>
      await SharedPreferences.getInstance();

  /// Lưu dữ liệu guest vào local storage
  /// Chỉ lưu các trường được cung cấp (không null)
  Future<void> saveGuestData({
    String? goal,
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
  }) async {
    final prefs = await _prefs;

    // Lưu từng trường nếu có giá trị
    if (goal != null) await prefs.setString(_keyGoal, goal);
    if (heightCm != null) await prefs.setDouble(_keyHeight, heightCm);
    if (weightKg != null) await prefs.setDouble(_keyWeight, weightKg);
    if (age != null) await prefs.setInt(_keyAge, age);
    if (gender != null) await prefs.setString(_keyGender, gender);
  }

  /// Đọc tất cả dữ liệu guest từ local storage
  /// Trả về Map với các key tương ứng với từng trường dữ liệu
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

  /// Kiểm tra xem có dữ liệu guest nào được lưu không
  /// Trả về true nếu có ít nhất một trường dữ liệu
  Future<bool> hasGuestData() async {
    final prefs = await _prefs;
    return prefs.containsKey(_keyGoal) ||
        prefs.containsKey(_keyHeight) ||
        prefs.containsKey(_keyWeight) ||
        prefs.containsKey(_keyAge) ||
        prefs.containsKey(_keyGender);
  }

  /// Xóa tất cả dữ liệu guest khỏi local storage
  /// Được gọi sau khi đồng bộ thành công với tài khoản chính thức
  Future<void> clearGuestData() async {
    final prefs = await _prefs;

    // Xóa từng key một cách tuần tự
    await prefs.remove(_keyGoal);
    await prefs.remove(_keyHeight);
    await prefs.remove(_keyWeight);
    await prefs.remove(_keyAge);
    await prefs.remove(_keyGender);
  }
}
