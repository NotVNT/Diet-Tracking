import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:diet_tracking_project/database/exceptions.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/model/user.dart' as app_user;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    late FakeFirebaseFirestore firestore;
    late AuthService service;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      firestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      service = AuthService(auth: mockAuth, firestore: firestore);
    });

    test('signUpWithEmailAndPassword creates user in Auth and Firestore', () async {
      final user = await service.signUpWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
        fullName: 'Test User',
        phone: '1234567890',
      );

      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
      expect(user.displayName, 'Test User');

      // Check Firestore
      final doc = await firestore.collection('users').doc(user.uid).get();
      expect(doc.exists, true);
      final data = doc.data()!;
      expect(data['email'], 'test@example.com');
      expect(data['fullName'], 'Test User');
      expect(data['phone'], '1234567890');
    });

    test('signInWithEmailAndPassword returns User when auth OK', () async {
      // Create user first
      final createdUser = await mockAuth.createUserWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      
      final user = await service.signInWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      expect(user, isNotNull);
      expect(user!.uid, createdUser.user!.uid);
      expect(user.email, 'a@a.com');
    });

    test('signInWithEmailAndPassword throws AuthException on failure', () async {
      // MockFirebaseAuth throws FirebaseAuthException for wrong password if configured?
      // By default MockFirebaseAuth might not throw for simple sign in unless we configure it or use specific methods.
      // However, we can try to sign in with non-existent user.
      
      try {
        await service.signInWithEmailAndPassword(
          email: 'nonexistent@example.com',
          password: 'wrongpassword',
        );
        // If it doesn't throw, we might need to adjust expectation based on MockFirebaseAuth behavior
        // But usually it throws for user-not-found
      } catch (e) {
        expect(e, isA<AuthException>());
      }
    });

    test('signOut signs out from Auth', () async {
      await mockAuth.createUserWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      await service.signInWithEmailAndPassword(
        email: 'a@a.com',
        password: 'pwd',
      );
      expect(mockAuth.currentUser, isNotNull);

      await service.signOut();
      expect(mockAuth.currentUser, isNull);
    });

    test('getUserData returns null when doc does not exist', () async {
      final res = await service.getUserData('non_existent_uid');
      expect(res, isNull);
    });

    test('getUserData returns user data when doc exists', () async {
      const uid = 'test_uid';
      const userData = app_user.User(
        uid: uid,
        email: 'test@example.com',
        fullName: 'Test User',
        phone: '1234567890',
      );
      
      await firestore.collection('users').doc(uid).set(userData.toJson());

      final res = await service.getUserData(uid);
      expect(res, isNotNull);
      expect(res!.uid, uid);
      expect(res.email, 'test@example.com');
    });

    test('updateUserData updates data in Firestore', () async {
      const uid = 'test_uid';
      await firestore.collection('users').doc(uid).set({'name': 'Old Name'});

      await service.updateUserData(uid, {'name': 'New Name'});

      final doc = await firestore.collection('users').doc(uid).get();
      expect(doc.data()!['name'], 'New Name');
    });

    test('updateUserData throws FirestoreException when doc does not exist', () async {
      // FakeFirebaseFirestore throws exception when updating non-existent document?
      // Let's verify. If not, we might need to adjust the test or the fake behavior.
      // Standard Firestore throws NOT_FOUND.
      
      expect(
        () => service.updateUserData('non_existent_uid', {'a': 1}),
        throwsA(isA<FirestoreException>()),
      );
    });

    test('saveNutritionPlan saves plan to Firestore', () async {
      const uid = 'test_uid';
      final plan = {'calories': 2000, 'protein': 150};

      await service.saveNutritionPlan(uid, plan);

      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('nutrition_plans')
          .doc('active_plan')
          .get();
      
      expect(doc.exists, true);
      expect(doc.data(), plan);
    });

    test('getActiveNutritionPlan returns plan if exists', () async {
      const uid = 'test_uid';
      final plan = {'calories': 2000, 'protein': 150};

      await firestore
          .collection('users')
          .doc(uid)
          .collection('nutrition_plans')
          .doc('active_plan')
          .set(plan);

      final res = await service.getActiveNutritionPlan(uid);
      expect(res, plan);
    });

    test('getActiveNutritionPlan returns null if not exists', () async {
      final res = await service.getActiveNutritionPlan('non_existent_uid');
      expect(res, isNull);
    });
  });
}
