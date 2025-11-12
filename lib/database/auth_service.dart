import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart' as app_user;
import '../model/body_info_model.dart';
import '../model/nutrition_calculation_model.dart';
import 'exceptions.dart';
import 'local_storage_service.dart';

/// Service để quản lý authentication và Firestore database
class AuthService {
  // Constants
  static const String _usersCollection = 'users';
  static const String _testCollection = 'test';

  // Firebase instances
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Đăng ký user mới với email và password
  /// Chỉ lưu vào Firestore khi đăng ký thành công
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    try {
      // Tạo user trong Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user != null) {
        // Cập nhật display name
        await user.updateDisplayName(fullName);

        // Tạo user object để lưu vào Firestore
        final app_user.User userData = app_user.User(
          uid: user.uid,
          email: email,
          fullName: fullName,
          phone: phone,
          avatars: user.photoURL,
        );

        // Lưu thông tin user vào Firestore
        await _saveUserToFirestore(user.uid, userData);

        return user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e), e.code);
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// Đăng nhập với email và password
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e), e.code);
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    // Xóa dữ liệu guest khi đăng xuất
    try {
      final LocalStorageService localStorage = LocalStorageService();
      await localStorage.clearGuestData();
    } catch (e) {
      // Log error if needed, for example: FirebaseCrashlytics.instance.recordError(e, stack);
    }
  }

  /// Lấy thông tin user từ Firestore
  Future<app_user.User?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .get();

      if (doc.exists) {
        return app_user.User.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw FirestoreException('Không thể lấy thông tin user: $e');
    }
  }

  /// Cập nhật thông tin user trong Firestore
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update(data);
    } catch (e) {
      throw FirestoreException('Không thể cập nhật thông tin user: $e');
    }
  }

  /// Lưu kế hoạch dinh dưỡng của người dùng
  Future<void> saveNutritionPlan(
    String uid,
    Map<String, dynamic> planData,
  ) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection('nutrition_plans')
          .doc('active_plan') // Giả sử mỗi user chỉ có 1 plan active
          .set(planData, SetOptions(merge: true));
    } catch (e) {
      throw FirestoreException('Không thể lưu kế hoạch dinh dưỡng: $e');
    }
  }

  /// Lấy kế hoạch dinh dưỡng đang hoạt động của người dùng
  Future<Map<String, dynamic>?> getActiveNutritionPlan(String uid) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection('nutrition_plans')
          .doc('active_plan')
          .get();

      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      throw FirestoreException('Không thể lấy kế hoạch dinh dưỡng: $e');
    }
  }

  /// Lấy và chuyển đổi kế hoạch dinh dưỡng cho bot
  Future<NutritionCalculation?> getNutritionPlanForCurrentUser() async {
    final user = currentUser;
    if (user == null) {
      return null; // Không có người dùng, không có kế hoạch
    }

    final planData = await getActiveNutritionPlan(user.uid);
    if (planData == null) {
      return null; // Người dùng chưa có kế hoạch
    }

    try {
      // Chuyển đổi Map thành đối tượng NutritionCalculation
      final nutritionPlan = NutritionCalculation.fromJson(planData);
      return nutritionPlan;
    } catch (e) {
      // Lỗi nếu cấu trúc dữ liệu trên Firestore không khớp
      throw Exception('Lỗi khi chuyển đổi dữ liệu kế hoạch dinh dưỡng: $e');
    }
  }

  /// Lấy các bản ghi thực phẩm gần đây của người dùng
  Future<List<Map<String, dynamic>>> getRecentFoodRecords(
    String uid, {
    int limit = 5,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection('food_records')
          .orderBy('date', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw FirestoreException('Không thể lấy lịch sử ăn uống: $e');
    }
  }

  /// Đăng ký user mới với dữ liệu on_boarding
  Future<User?> signUpWithOnboardingData({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? goalWeightKg,
    List<String>? medicalConditions,
    List<String>? allergies,
    int? age,
    String? goal,
  }) async {
    try {
      // Tạo user trong Firebase Auth
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = result.user;

      if (user != null) {
        // Cập nhật display name
        await user.updateDisplayName(fullName);

        // Tạo body info object
        final BodyInfoModel bodyInfo = BodyInfoModel(
          heightCm: heightCm,
          weightKg: weightKg,
          goalWeightKg: goalWeightKg,
        );

        // Tạo user object với dữ liệu on_boarding
        final app_user.User userData = app_user.User(
          uid: user.uid,
          email: email,
          fullName: fullName,
          phone: phone,
          gender: _parseGender(gender),
          bodyInfo: bodyInfo.copyWith(
            medicalConditions: medicalConditions,
            allergies: allergies,
          ),
          age: age,
          goal: goal,
          avatars: user.photoURL,
        );

        // Lưu thông tin user vào Firestore
        await _saveUserToFirestore(user.uid, userData);

        return user;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e), e.code);
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi không mong muốn: $e');
    }
  }

  /// Parse gender string to GenderType enum
  app_user.GenderType? _parseGender(String? gender) {
    if (gender == null) return null;
    switch (gender.toLowerCase()) {
      case 'male':
        return app_user.GenderType.male;
      case 'female':
        return app_user.GenderType.female;
      case 'other':
        return app_user.GenderType.other;
      default:
        return null;
    }
  }

  /// Xử lý các lỗi authentication
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng. Vui lòng chọn email khác.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau.';
      case 'operation-not-allowed':
        return 'Thao tác này không được phép.';
      case 'invalid-credential':
        return 'Thông tin đăng nhập không hợp lệ.';
      default:
        return 'Đã xảy ra lỗi: ${e.message}';
    }
  }

  /// Kiểm tra email đã tồn tại chưa
  Future<bool> isEmailAlreadyInUse(String email) async {
    // Tạm thời bỏ qua kiểm tra email trước
    // Firebase Auth sẽ tự động báo lỗi nếu email đã tồn tại
    return false;
  }

  /// Gửi email xác thực
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  /// Gửi email reset password
  Future<void> sendPasswordResetEmail(String email) async {
    final String sanitizedEmail = email.trim();
    if (sanitizedEmail.isEmpty) {
      throw const AuthException('Email không hợp lệ.', 'invalid-email');
    }

    String emailForReset = sanitizedEmail;

    try {
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(emailForReset);

      if (signInMethods.isEmpty) {
        final String lowerCaseEmail = sanitizedEmail.toLowerCase();
        if (lowerCaseEmail != sanitizedEmail) {
          signInMethods =
              await _auth.fetchSignInMethodsForEmail(lowerCaseEmail);
          if (signInMethods.isNotEmpty) {
            emailForReset = lowerCaseEmail;
          }
        }

        if (signInMethods.isEmpty) {
          final bool exists =
              await _doesUserExistByEmail(emailForReset);
          if (!exists && lowerCaseEmail != sanitizedEmail) {
            final bool existsLower =
                await _doesUserExistByEmail(lowerCaseEmail);
            if (existsLower) {
              emailForReset = lowerCaseEmail;
            } else {
              throw const AuthException(
                'Email không tồn tại trong hệ thống.',
                'user-not-found',
              );
            }
          } else if (!exists) {
            throw const AuthException(
              'Email không tồn tại trong hệ thống.',
              'user-not-found',
            );
          }
        }
      }

      if (signInMethods.isNotEmpty &&
          !signInMethods.contains('password')) {
        final String providers =
            signInMethods.map(_providerDisplayName).join(', ');
        throw AuthException(
          'Tài khoản này đang đăng nhập bằng: $providers. Không thể đặt lại mật khẩu bằng email.',
          'requires-different-provider',
        );
      }

      await _auth.sendPasswordResetEmail(email: emailForReset);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleAuthException(e), e.code);
    }
  }

  Future<bool> _doesUserExistByEmail(String email) async {
    final String lowerCaseEmail = email.trim().toLowerCase();

    final QuerySnapshot<Map<String, dynamic>> normalizedSnapshot = await _firestore
        .collection(_usersCollection)
        .where('emailLowercase', isEqualTo: lowerCaseEmail)
        .limit(1)
        .get();

    if (normalizedSnapshot.docs.isNotEmpty) {
      return true;
    }

    final QuerySnapshot<Map<String, dynamic>> legacySnapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();

    return legacySnapshot.docs.isNotEmpty;
  }

  String _providerDisplayName(String providerId) {
    switch (providerId) {
      case 'password':
        return 'Email & Mật khẩu';
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      case 'apple.com':
        return 'Apple';
      default:
        return providerId;
    }
  }

  /// Test kết nối Firebase
  Future<bool> testFirebaseConnection() async {
    try {
      // Test Firebase Auth
      _auth.currentUser;

      // Test Firestore
      await _firestore.collection(_testCollection).limit(1).get();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Private helper methods

  /// Lưu user data vào Firestore
  Future<void> _saveUserToFirestore(String uid, app_user.User userData) async {
    await _firestore
        .collection(_usersCollection)
        .doc(uid)
        .set(userData.toJson());
  }

  // Removed parsing health since we no longer store health in Firestore
}
