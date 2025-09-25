import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:diet_tracking_project/database/exceptions.dart';
import 'package:diet_tracking_project/database/auth_service.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

void main() {
  group('AuthService', () {
    late FakeFirebaseFirestore firestore;
    late AuthService service;
    late _MockFirebaseAuth mockAuth;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      mockAuth = _MockFirebaseAuth();
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
  });
}
