import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:diet_tracking_project/database/data_migration_service.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/database/auth_service.dart';

@GenerateMocks([LocalStorageService, AuthService])
import 'data_migration_service_test.mocks.dart';

void main() {
  late DataMigrationService service;
  late MockLocalStorageService mockLocal;
  late MockAuthService mockAuth;

  setUp(() {
    mockLocal = MockLocalStorageService();
    mockAuth = MockAuthService();
    service = DataMigrationService(local: mockLocal, auth: mockAuth);
  });

  group('DataMigrationService', () {
    test('syncGuestToUser does nothing if no guest data', () async {
      when(mockLocal.hasGuestData()).thenAnswer((_) async => false);

      await service.syncGuestToUser('test-uid');

      verify(mockLocal.hasGuestData()).called(1);
      verifyNever(mockLocal.readGuestData());
      verifyNever(mockAuth.updateUserData(any, any));
    });

    test('syncGuestToUser syncs data correctly', () async {
      when(mockLocal.hasGuestData()).thenAnswer((_) async => true);
      when(mockLocal.readGuestData()).thenAnswer((_) async => {
            'heightCm': 180.0,
            'weightKg': 75.0,
            'age': 30,
            'gender': 'Male',
            'goal': 'Lose Weight',
            'allergies': ['Peanuts'],
            'goalWeightKg': 70.0,
            'activityLevel': 'Active',
          });
      when(mockLocal.getData('nutrition_plan')).thenAnswer((_) async => null);
      when(mockAuth.updateUserData(any, any)).thenAnswer((_) async => {});
      when(mockLocal.clearGuestData()).thenAnswer((_) async => {});

      await service.syncGuestToUser('test-uid');

      verify(mockAuth.updateUserData('test-uid', argThat(predicate((map) {
        final m = map as Map<String, dynamic>;
        final bodyInfo = m['bodyInfo'] as Map<String, dynamic>;
        return bodyInfo['heightCm'] == 180.0 &&
            bodyInfo['weightKg'] == 75.0 &&
            bodyInfo['allergies'].contains('Peanuts') &&
            bodyInfo['goalWeightKg'] == 70.0 &&
            bodyInfo['activityLevel'] == 'Active' &&
            m['age'] == 30 &&
            m['gender'] == 'Male' &&
            m['goal'] == 'Lose Weight';
      })))).called(1);
      verify(mockLocal.clearGuestData()).called(1);
    });

    test('syncGuestToUser syncs nutrition plan if available', () async {
      when(mockLocal.hasGuestData()).thenAnswer((_) async => true);
      when(mockLocal.readGuestData()).thenAnswer((_) async => {
            'heightCm': 180.0,
          });
      final nutritionPlan = {'calories': 2000};
      when(mockLocal.getData('nutrition_plan')).thenAnswer((_) async => nutritionPlan);
      when(mockAuth.updateUserData(any, any)).thenAnswer((_) async => {});
      when(mockAuth.saveNutritionPlan(any, any)).thenAnswer((_) async => {});
      when(mockLocal.clearGuestData()).thenAnswer((_) async => {});

      await service.syncGuestToUser('test-uid');

      verify(mockAuth.saveNutritionPlan('test-uid', nutritionPlan)).called(1);
    });
  });
}
