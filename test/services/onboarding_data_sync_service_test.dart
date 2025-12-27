import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/services/onboarding_data_sync_service.dart';

class _LocalStorageStub extends LocalStorageService {
  _LocalStorageStub({
    required this.hasData,
    required this.guestData,
    this.targetDays,
  });

  final bool hasData;
  final Map<String, dynamic> guestData;
  final int? targetDays;

  var clearCalled = false;

  @override
  Future<bool> hasGuestData() async => hasData;

  @override
  Future<Map<String, dynamic>> readGuestData() async => guestData;

  @override
  Future<dynamic> getData(String key) async {
    if (key == 'targetDays') return targetDays;
    return null;
  }

  @override
  Future<void> clearGuestData() async {
    clearCalled = true;
  }
}

class _AuthStub extends AuthService {
  _AuthStub() : super(auth: MockFirebaseAuth(), firestore: FakeFirebaseFirestore());

  Map<String, dynamic>? lastUpdate;
  String? lastUid;
  bool throwOnUpdate = false;

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    if (throwOnUpdate) throw Exception('boom');
    lastUid = uid;
    lastUpdate = data;
  }
}

void main() {
  group('OnboardingDataSyncService', () {
    test('no-op when current user is null', () async {
      final local = _LocalStorageStub(hasData: true, guestData: {'age': 20});
      final auth = _AuthStub();
      final firebaseAuth = MockFirebaseAuth(signedIn: false);

      final svc = OnboardingDataSyncService(
        localStorage: local,
        authService: auth,
        firebaseAuth: firebaseAuth,
      );

      await svc.syncGuestOnboardingToCurrentUser();
      expect(auth.lastUpdate, isNull);
      expect(local.clearCalled, isFalse);
    });

    test('no-op when there is no guest data', () async {
      final local = _LocalStorageStub(hasData: false, guestData: {});
      final auth = _AuthStub();
      final firebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );

      final svc = OnboardingDataSyncService(
        localStorage: local,
        authService: auth,
        firebaseAuth: firebaseAuth,
      );

      await svc.syncGuestOnboardingToCurrentUser();
      expect(auth.lastUpdate, isNull);
      expect(local.clearCalled, isFalse);
    });

    test('updates user data and clears guest data on success', () async {
      final local = _LocalStorageStub(
        hasData: true,
        guestData: {
          'heightCm': 175.0,
          'weightKg': 80.0,
          'goalWeightKg': 75.0,
          'allergies': ['A'],
          'activityLevel': 'Ít vận động',
          'age': 30,
          'gender': 'Nam',
          'goal': 'Giảm cân',
        },
        targetDays: 30,
      );
      final auth = _AuthStub();
      final firebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );

      final svc = OnboardingDataSyncService(
        localStorage: local,
        authService: auth,
        firebaseAuth: firebaseAuth,
      );

      await svc.syncGuestOnboardingToCurrentUser();

      expect(auth.lastUid, 'u1');
      expect(auth.lastUpdate, isNotNull);
      expect(auth.lastUpdate!['age'], 30);
      expect(auth.lastUpdate!['gender'], 'Nam');
      expect(auth.lastUpdate!['goal'], 'Giảm cân');
      expect(auth.lastUpdate!['targetDays'], 30);

      final bodyInfo = auth.lastUpdate!['bodyInfo'] as Map<String, dynamic>;
      expect(bodyInfo['heightCm'], 175.0);
      expect(bodyInfo['weightKg'], 80.0);
      expect(bodyInfo['goalWeightKg'], 75.0);
      expect(bodyInfo['allergies'], ['A']);
      expect(bodyInfo['activityLevel'], 'Ít vận động');

      expect(local.clearCalled, isTrue);
    });

    test('swallows errors and does not clear guest data if update fails', () async {
      final local = _LocalStorageStub(
        hasData: true,
        guestData: {
          'age': 30,
          'gender': 'Nam',
        },
      );
      final auth = _AuthStub()..throwOnUpdate = true;
      final firebaseAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'u1'),
      );

      final svc = OnboardingDataSyncService(
        localStorage: local,
        authService: auth,
        firebaseAuth: firebaseAuth,
      );

      await svc.syncGuestOnboardingToCurrentUser();
      expect(local.clearCalled, isFalse);
    });
  });
}
