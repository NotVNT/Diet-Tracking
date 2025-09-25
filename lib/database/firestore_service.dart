import 'package:cloud_firestore/cloud_firestore.dart';

/// Service để quản lý các thao tác với Firestore database
class FirestoreService {
  // Constants
  static const String _usersCollection = 'users';
  static const String _testCollection = 'test';

  // Firebase instance
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy instance của Firestore
  FirebaseFirestore get firestore => _firestore;

  /// Kiểm tra kết nối Firestore
  Future<bool> testConnection() async {
    try {
      await _firestore.collection(_testCollection).limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Lấy tất cả users
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection(_usersCollection).snapshots();
  }

  /// Lấy user theo ID
  Future<DocumentSnapshot> getUserById(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).get();
  }

  /// Xóa user
  Future<void> deleteUser(String userId) {
    return _firestore.collection(_usersCollection).doc(userId).delete();
  }

  /// Kiểm tra user có tồn tại không
  Future<bool> userExists(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    return doc.exists;
  }
}
