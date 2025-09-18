import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthenticationService {
  static final AuthenticationService _instance =
      AuthenticationService._internal();
  factory AuthenticationService() => _instance;
  AuthenticationService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Đăng ký tài khoản mới
  Future<UserCredential> signUp(
    String email,
    String password,
    Map<String, dynamic> userData,
  ) async {
    try {
      print('📝 Đang tạo tài khoản mới với email: $email');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Lưu thông tin user vào Firestore
      if (userCredential.user != null) {
        await _firestoreService.createUser(userCredential.user!.uid, userData);
      }

      print('✅ Đăng ký thành công');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Lỗi đăng ký: $e');
      if (e.code == 'weak-password') {
        throw Exception('Mật khẩu quá yếu');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email đã được sử dụng');
      }
      throw Exception('Lỗi đăng ký: ${e.message}');
    }
  }

  // Đăng nhập
  Future<UserCredential> signIn(String email, String password) async {
    try {
      print('🔑 Đang đăng nhập với email: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('✅ Đăng nhập thành công');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('❌ Lỗi đăng nhập: $e');
      if (e.code == 'user-not-found') {
        throw Exception('Không tìm thấy tài khoản');
      } else if (e.code == 'wrong-password') {
        throw Exception('Sai mật khẩu');
      }
      throw Exception('Lỗi đăng nhập: ${e.message}');
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      print('🚪 Đang đăng xuất');
      await _auth.signOut();
      print('✅ Đăng xuất thành công');
    } catch (e) {
      print('❌ Lỗi đăng xuất: $e');
      throw Exception('Không thể đăng xuất: $e');
    }
  }

  // Kiểm tra trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Lấy user hiện tại
  User? get currentUser => _auth.currentUser;
}
