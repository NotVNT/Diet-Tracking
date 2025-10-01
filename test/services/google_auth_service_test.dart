import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'package:diet_tracking_project/services/google_auth_service.dart';

// Mocks cho Firebase Auth
class MockFirebaseAuth extends Mock implements fb_auth.FirebaseAuth {}

class MockUserCredential extends Mock implements fb_auth.UserCredential {}

class MockUser extends Mock implements fb_auth.User {}

class MockUserInfo extends Mock implements fb_auth.UserInfo {}

void main() {
  group('GoogleAuthService', () {
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      mockAuth = MockFirebaseAuth();
      fakeFirestore = FakeFirebaseFirestore();
    });

    test('signInWithGoogle (mobile) tạo user doc nếu chưa tồn tại', () async {
      // Arrange
      final mockCred = MockUserCredential();

      when(
        mockCred.user,
      ).thenReturn(null); // không dùng fb user thật trong test

      final service = GoogleAuthService(
        auth: mockAuth,
        firestore: fakeFirestore,
        signInWithProviderFn: (provider) async => mockCred,
      );

      final provider = fb_auth.GoogleAuthProvider();

      // Act
      await service.signInWithGoogle(
        providerOverride: provider,
        userInfoOverride: const {
          'uid': 'uid_1',
          'email': 'u1@example.com',
          'displayName': 'User One',
          'photoURL': 'https://example.com/a.png',
        },
      );

      // Assert
      final DocumentSnapshot<Map<String, dynamic>> doc = await fakeFirestore
          .collection('users')
          .doc('uid_1')
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['email'], 'u1@example.com');
      expect(doc.data()!['fullName'], 'User One');
      expect(doc.data()!['avatarUrl'], 'https://example.com/a.png');
    });

    test('signInWithGoogle trả về null khi user = null', () async {
      // Arrange
      final mockCred = MockUserCredential();
      when(mockCred.user).thenReturn(null);

      final service = GoogleAuthService(
        auth: mockAuth,
        firestore: fakeFirestore,
        signInWithProviderFn: (provider) async => mockCred,
      );
      final provider = fb_auth.GoogleAuthProvider();

      // Act
      final fbUser = await service.signInWithGoogle(providerOverride: provider);

      // Assert
      expect(fbUser, isNull);
      final qs = await fakeFirestore.collection('users').get();
      expect(qs.docs, isEmpty);
    });

    test('signOut gọi FirebaseAuth.signOut()', () async {
      // Arrange
      bool called = false;
      final service = GoogleAuthService(
        auth: mockAuth,
        firestore: fakeFirestore,
        signOutFn: () async {
          called = true;
        },
      );

      // Act
      await service.signOut();

      // Assert
      expect(called, isTrue);
    });

    test('disconnectGoogle không throw khi không có currentUser', () async {
      // Arrange
      when(mockAuth.currentUser).thenReturn(null);
      final service = GoogleAuthService(
        auth: mockAuth,
        firestore: fakeFirestore,
      );

      // Act & Assert
      await expectLater(service.disconnectGoogle(), completes);
    });
  });
}
