import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseService {
  static final FirebaseDatabaseService _instance =
      FirebaseDatabaseService._internal();
  factory FirebaseDatabaseService() => _instance;
  FirebaseDatabaseService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Tạo user mới
  Future<void> createUser(String uid, Map<String, dynamic> userData) async {
    try {
      print('📝 Đang tạo user mới với ID: $uid');
      await _database.child('users').child(uid).set(userData);
      print('✅ Tạo user thành công');
    } catch (e) {
      print('❌ Lỗi khi tạo user: $e');
      throw Exception('Không thể tạo user: $e');
    }
  }

  // Lấy thông tin user
  Future<Map?> getUser(String uid) async {
    try {
      print('🔍 Đang tìm user với ID: $uid');
      final snapshot = await _database.child('users').child(uid).get();
      if (snapshot.exists) {
        print('✅ Đã tìm thấy user');
        return snapshot.value as Map;
      }
      print('⚠️ Không tìm thấy user');
      return null;
    } catch (e) {
      print('❌ Lỗi khi lấy thông tin user: $e');
      throw Exception('Không thể lấy thông tin user: $e');
    }
  }

  // Cập nhật thông tin user
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      print('🔄 Đang cập nhật user với ID: $uid');
      await _database.child('users').child(uid).update(updates);
      print('✅ Cập nhật user thành công');
    } catch (e) {
      print('❌ Lỗi khi cập nhật user: $e');
      throw Exception('Không thể cập nhật user: $e');
    }
  }
}
