import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/model/target_days_view_model.dart';
import 'package:diet_tracking_project/services/nutrition_calculator_service.dart';

class _LocalStorageStub extends LocalStorageService {
  _LocalStorageStub({required this.guestData});

  final Map<String, dynamic> guestData;

  final Map<String, dynamic> saved = {};

  @override
  Future<Map<String, dynamic>> readGuestData() async => guestData;

  @override
  Future<void> saveData(String key, dynamic data) async {
    saved[key] = data;
  }
}

void main() {
  group('TargetDaysViewModel', () {
    test('load: sets userInfo + calculation when guest data complete', () async {
      final local = _LocalStorageStub(
        guestData: {
          'age': 30,
          'gender': 'Male',
          'heightCm': 175.0,
          'weightKg': 80.0,
          'goalWeightKg': 75.0,
          'activityLevel': 'Ít vận động',
        },
      );

      final vm = TargetDaysViewModel(localStorage: local, initialDays: 30);
      await vm.load();

      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
      expect(vm.userInfo, isNotNull);
      expect(vm.calculation, isNotNull);
      expect(vm.selectedDays, 30);
      expect(vm.calculation!.targetDays, 30);

      final expectedRecommended = NutritionCalculatorService.calculateRecommendedDays(
        userInfo: vm.userInfo!,
      );
      expect(vm.recommendedDays, expectedRecommended);
    });

    test('load: sets errorMessage when required guest data missing', () async {
      final local = _LocalStorageStub(
        guestData: {
          'age': 30,
          // missing gender/height/weight/goalWeight/activityLevel
        },
      );

      final vm = TargetDaysViewModel(localStorage: local, initialDays: 30);
      await vm.load();

      expect(vm.isLoading, isFalse);
      expect(vm.userInfo, isNull);
      expect(vm.calculation, isNull);
      expect(vm.errorMessage, isNotNull);
    });

    test('setSelectedDays: updates selectedDays and recalculates', () async {
      final local = _LocalStorageStub(
        guestData: {
          'age': 30,
          'gender': 'Male',
          'heightCm': 175.0,
          'weightKg': 80.0,
          'goalWeightKg': 75.0,
          'activityLevel': 'Ít vận động',
        },
      );

      final vm = TargetDaysViewModel(localStorage: local, initialDays: 30);
      await vm.load();

      vm.setSelectedDays(14);

      expect(vm.selectedDays, 14);
      expect(vm.calculation, isNotNull);
      expect(vm.calculation!.targetDays, 14);
    });

    test('persistSelection: returns false when calculation is null', () async {
      final local = _LocalStorageStub(guestData: {});
      final vm = TargetDaysViewModel(localStorage: local, initialDays: 30);

      // Force error state.
      await vm.load();
      expect(vm.calculation, isNull);

      final ok = await vm.persistSelection();
      expect(ok, isFalse);
      expect(local.saved, isEmpty);
    });

    test('persistSelection: saves targetDays and nutritionCalculation json', () async {
      final local = _LocalStorageStub(
        guestData: {
          'age': 30,
          'gender': 'Male',
          'heightCm': 175.0,
          'weightKg': 80.0,
          'goalWeightKg': 75.0,
          'activityLevel': 'Ít vận động',
        },
      );

      final vm = TargetDaysViewModel(localStorage: local, initialDays: 30);
      await vm.load();

      vm.setSelectedDays(60);
      final ok = await vm.persistSelection();

      expect(ok, isTrue);
      expect(local.saved['targetDays'], 60);
      expect(local.saved['nutritionCalculation'], isA<Map<String, dynamic>>());

      final calcMap = local.saved['nutritionCalculation'] as Map<String, dynamic>;
      expect(calcMap['targetDays'], 60);
      expect(calcMap.containsKey('targetCalories'), isTrue);
    });
  });
}
