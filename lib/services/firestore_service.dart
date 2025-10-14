import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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
    return _firestore.collection(_usersCollection).doc(userId).get();
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

  /// 👤 Lấy thông tin user đang đăng nhập
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection(_usersCollection)
        .doc(user.uid)
        .get();
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
    return load_history_from_firestore(uid);
  }

  /// 💬 Gửi prompt tới API (FastAPI -> Gemini) và LƯU LỊCH SỬ theo yêu cầu
  /// Quy trình:
  /// - Load toàn bộ history hiện tại từ Firestore
  /// - Append message USER
  /// - Gọi backend để lấy reply
  /// - Append message MODEL
  /// - Lưu TOÀN BỘ lịch sử lại vào Firestore (append-only)
  Future<String> sendMessageToChatbox(String prompt) async {
    // 0) Lấy user info để gửi kèm backend như trước đây
    final userData = await getCurrentUserData();
    if (userData == null) {
      throw Exception(
        "Chưa đăng nhập hoặc không tìm thấy user trong Firestore",
      );
    }
    final uid = _requireUid();

    // 1) Load toàn bộ lịch sử hiện tại
    final history = await load_history_from_firestore(uid);

    // 2) Append message mới của user (append-only)
    history.add(
      ChatMessage(
        role: 'user',
        content: prompt,
        timestamp: DateTime.now().toUtc(),
      ),
    );

    // 3) Gọi backend (FastAPI endpoint như cũ, KHÔNG đụng chat_bot)
    final url = Uri.parse(
      'http://localhost:8000/chat',
    ); // đổi thành server thật khi deploy

    final body = jsonEncode({
      'prompt': prompt,
      'age': userData['age'],
      'height': userData['height'],
      'weight': userData['weight'],
      'disease': userData['disease'],
      'goal': userData['goal'],
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      // Không append message model khi lỗi
      throw Exception('Lỗi chatbox: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final reply = (data['reply'] ?? '').toString();

    // 4) Append message của bot/model
    history.add(
      ChatMessage(
        role: 'model',
        content: reply,
        timestamp: DateTime.now().toUtc(),
      ),
    );

    // 5) Lưu TOÀN BỘ lịch sử vào Firestore (đúng SYSTEM PROMPT)
    await save_history_to_firestore(uid, history);

    // 6) Trả về reply
    return reply;
  }
}
