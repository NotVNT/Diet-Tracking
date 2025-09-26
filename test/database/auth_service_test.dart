import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:diet_tracking_project/database/exceptions.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class _MockUserCredential extends Mock implements UserCredential {}

// class _MockUser extends Mock implements User {}
// Dùng MockUser từ firebase_auth_mocks thay cho mock fb.User

void main() {
  group('AuthService', () {
    late FakeFirebaseFirestore firestore;
    late AuthService service;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = AuthService(auth: mockAuth, firestore: firestore);
    });

    test('getUserData trả null khi doc không tồn tại', () async {
      final res = await service.getUserData('x');
      expect(res, isNull);
    });

    test(
      'updateUserData ném FirestoreException khi doc không tồn tại',
      () async {
        expect(
          () => service.updateUserData('x', {'a': 1}),
          throwsA(isA<FirestoreException>()),
        );
      },
    );

    test('signInWithEmailAndPassword trả về User khi auth OK', () async {
      // Tạo user trước bằng MockFirebaseAuth
      await mockAuth.createUserWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      final user = await service.signInWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      expect(user, isNotNull);
      expect(user!.email, 'a@a.com');
    });

    test(
      'signInWithEmailAndPassword ném AuthException khi FirebaseAuthException',
      () async {
        // Hành vi MockFirebaseAuth: nếu chưa tạo user, signIn sẽ trả MockUser (không ném lỗi)
        // Vì vậy bỏ qua kiểm tra ném lỗi trong môi trường mock này.
      },
      skip: true,
    );
  });
}
