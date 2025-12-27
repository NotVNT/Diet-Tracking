import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/delete_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/get_food_records_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/save_food_record_usecase.dart';

import '../../mocks.mocks.dart';

void main() {
  group('record_view_home usecases', () {
    late MockFoodRecordRepository repository;

    setUp(() {
      repository = MockFoodRecordRepository();
    });

    test('GetFoodRecordsUseCase calls repository and returns records', () async {
      final records = <FoodRecordEntity>[
        FoodRecordEntity(
          id: '1',
          foodName: 'Apple',
          calories: 95,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
      ];

      when(repository.getFoodRecords()).thenAnswer((_) async => records);

      final usecase = GetFoodRecordsUseCase(repository);
      final result = await usecase.call();

      expect(result, records);
      verify(repository.getFoodRecords()).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('DeleteFoodRecordUseCase calls repository.deleteFoodRecord', () async {
      when(repository.deleteFoodRecord('abc')).thenAnswer((_) async {});

      final usecase = DeleteFoodRecordUseCase(repository);
      await usecase.call('abc');

      verify(repository.deleteFoodRecord('abc')).called(1);
      verifyNoMoreInteractions(repository);
    });

    test('SaveFoodRecordUseCase builds entity and saves via repository', () async {
      when(repository.saveFoodRecord(any)).thenAnswer((_) async {});

      final before = DateTime.now();

      final usecase = SaveFoodRecordUseCase(repository);
      await usecase.call(
        'Chicken salad',
        350,
        protein: 30,
        carbs: 20,
        fat: 12,
        reason: 'Healthy',
        nutritionDetails: 'Protein: 30g',
        recordType: RecordType.manual,
      );

      final after = DateTime.now();

      final captured = verify(repository.saveFoodRecord(captureAny)).captured;
      expect(captured.length, 1);

      final entity = captured.single as FoodRecordEntity;
      expect(entity.foodName, 'Chicken salad');
      expect(entity.calories, 350);
      expect(entity.protein, 30);
      expect(entity.carbs, 20);
      expect(entity.fat, 12);
      expect(entity.reason, 'Healthy');
      expect(entity.nutritionDetails, 'Protein: 30g');
      expect(entity.recordType, RecordType.manual);

      // Generated fields
      expect(entity.id, isNotNull);
      expect(entity.date.isAfter(before) || entity.date.isAtSameMomentAs(before), isTrue);
      expect(entity.date.isBefore(after) || entity.date.isAtSameMomentAs(after), isTrue);

      verifyNoMoreInteractions(repository);
    });
  });
}
