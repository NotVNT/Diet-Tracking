import 'package:firebase_auth/firebase_auth.dart';

import '../database/auth_service.dart';
import '../database/local_storage_service.dart';

class OnboardingDataSyncService {
  final LocalStorageService _localStorage;
  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;

  OnboardingDataSyncService({
    required LocalStorageService localStorage,
    required AuthService authService,
    FirebaseAuth? firebaseAuth,
  }) : _localStorage = localStorage,
       _authService = authService,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Sync onboarding data stored locally (guest) to Firestore for current user.
  ///
  /// Behavior is intentionally conservative:
  /// - No-op if user is null
  /// - No-op if there is no guest data
  /// - Clears guest data only after a successful update
  /// - Swallows errors (UI flow should proceed regardless)
  Future<void> syncGuestOnboardingToCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final hasData = await _localStorage.hasGuestData();
      if (!hasData) return;

      final data = await _localStorage.readGuestData();

      final Map<String, dynamic> update = {};

      final bodyInfo = {
        if (data['heightCm'] != null) 'heightCm': data['heightCm'],
        if (data['weightKg'] != null) 'weightKg': data['weightKg'],
        if (data['goalWeightKg'] != null) 'goalWeightKg': data['goalWeightKg'],
        if (data['allergies'] != null) 'allergies': data['allergies'],
        if (data['activityLevel'] != null)
          'activityLevel': data['activityLevel'],
      };

      if (bodyInfo.isNotEmpty) {
        update['bodyInfo'] = bodyInfo;
      }

      if (data['age'] != null) {
        update['age'] = data['age'];
      }
      if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
        update['gender'] = data['gender'];
      }
      if (data['goal'] != null && (data['goal'] as String).isNotEmpty) {
        update['goal'] = data['goal'];
      }

      final targetDays = await _localStorage.getData('targetDays') as int?;
      if (targetDays != null) {
        update['targetDays'] = targetDays;
      }

      if (update.isEmpty) return;

      await _authService.updateUserData(user.uid, update);

      await _localStorage.clearGuestData();
    } catch (_) {
      // Intentionally ignored; caller should continue flow regardless.
    }
  }
}
