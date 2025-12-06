import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_history_service.dart';

/// Service để quản lý user và gửi dữ liệu cho chatbox (Gemini qua FastAPI)
/// Đồng thời THỰC THI SYSTEM PROMPT: lưu lịch sử chat vào Firestore ở phía Dart
class FirestoreService {
  // Collections
  static const String _usersCollection = 'users';
  static const String _testCollection = 'test';

  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  FirebaseFirestore get firestore => _firestore;

  /// 🔌 Kiểm tra kết nối Firestore
  Future<bool> testConnection() async {
    try {
      await _firestore.collection(_testCollection).limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 📥 Lấy tất cả users
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection(_usersCollection).snapshots();
  }

  /// 📥 Lấy user theo ID
  Future<DocumentSnapshot> getUserById(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .get(const GetOptions(source: Source.server));
  }

  /// ❌ Xóa user
  Future<void> deleteUser(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).delete();
  }

  /// 🔍 Kiểm tra user có tồn tại
  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    return doc.exists;
  }

  /// ✍️ Cập nhật hoặc tạo mới thông tin user
  Future<void> updateUser(String userId, Map<String, dynamic> data) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .set(data, SetOptions(merge: true));
  }

  /// 👤 Lấy thông tin user đang đăng nhập
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .get(const GetOptions(source: Source.server));

    // ignore: avoid_print
    print('[FirestoreService] current uid=${user.uid}');
    return doc.data();
  }

  /// Trả về UID user hiện tại (throw nếu chưa đăng nhập)
  String _requireUid() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    return user.uid;
  }

  /// Tải toàn bộ lịch sử chat của user hiện tại (để UI gọi sau khi đăng nhập)
  Future<List<ChatMessage>> loadChatHistoryForCurrentUser() async {
    final uid = _requireUid();
    return loadHistoryFromFirestore(uid);
  }
}
