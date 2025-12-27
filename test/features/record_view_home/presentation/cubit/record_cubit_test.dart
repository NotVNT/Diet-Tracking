import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/delete_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/get_food_records_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/usecases/save_food_record_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_cubit.dart';
import 'package:diet_tracking_project/features/record_view_home/presentation/cubit/record_state.dart';

import '../../mocks.mocks.dart';

void main() {
  group('RecordCubit', () {
    late MockFoodRecordRepository repository;
    late RecordCubit cubit;

    setUp(() {
      repository = MockFoodRecordRepository();
      cubit = RecordCubit(
        SaveFoodRecordUseCase(repository),
        GetFoodRecordsUseCase(repository),
        DeleteFoodRecordUseCase(repository),
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is RecordInitial', () {
      expect(cubit.state, isA<RecordInitial>());
    });

    test('loadFoodRecords emits Loading then RecordListLoaded', () async {
      final records = <FoodRecordEntity>[
        FoodRecordEntity(
          id: '1',
          foodName: 'Apple',
          calories: 95,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
        FoodRecordEntity(
          id: '2',
          foodName: 'Banana',
          calories: 105,
          date: DateTime(2025, 1, 2),
          recordType: RecordType.manual,
        ),
      ];

      when(repository.getFoodRecords()).thenAnswer((_) async => records);

      final states = <RecordState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadFoodRecords();
      await Future<void>.delayed(Duration.zero);

      expect(states.first, isA<RecordLoading>());
      expect(states.last, isA<RecordListLoaded>());

      final loaded = states.last as RecordListLoaded;
      expect(loaded.records, records);
      expect(loaded.filteredRecords, records);

      await sub.cancel();
    });

    test('setSearchQuery filters records by foodName case-insensitively', () async {
      final records = <FoodRecordEntity>[
        FoodRecordEntity(
          id: '1',
          foodName: 'Chicken Salad',
          calories: 350,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
        FoodRecordEntity(
          id: '2',
          foodName: 'Apple',
          calories: 95,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
      ];

      when(repository.getFoodRecords()).thenAnswer((_) async => records);

      await cubit.loadFoodRecords();
      expect(cubit.state, isA<RecordListLoaded>());

      cubit.setSearchQuery('apple');
      final state = cubit.state as RecordListLoaded;
      expect(state.filteredRecords.length, 1);
      expect(state.filteredRecords.single.foodName, 'Apple');
    });

    test('setFilters applies calorie range and date range', () async {
      final records = <FoodRecordEntity>[
        FoodRecordEntity(
          id: '1',
          foodName: 'LowCal',
          calories: 100,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
        FoodRecordEntity(
          id: '2',
          foodName: 'HighCal',
          calories: 500,
          date: DateTime(2025, 1, 10),
          recordType: RecordType.manual,
        ),
      ];
      when(repository.getFoodRecords()).thenAnswer((_) async => records);

      await cubit.loadFoodRecords();

      cubit.setFilters(
        calorieRange: '0-200',
        dateRange: DateTimeRange(
          start: DateTime(2025, 1, 1),
          end: DateTime(2025, 1, 5),
        ),
      );

      final state = cubit.state as RecordListLoaded;
      expect(state.filteredRecords.length, 1);
      expect(state.filteredRecords.single.id, '1');
      expect(cubit.hasActiveFilters, isTrue);
    });

    test('deleteFoodRecord removes record and emits updated RecordListLoaded', () async {
      final records = <FoodRecordEntity>[
        FoodRecordEntity(
          id: '1',
          foodName: 'Apple',
          calories: 95,
          date: DateTime(2025, 1, 1),
          recordType: RecordType.manual,
        ),
        FoodRecordEntity(
          id: '2',
          foodName: 'Banana',
          calories: 105,
          date: DateTime(2025, 1, 2),
          recordType: RecordType.manual,
        ),
      ];

      when(repository.getFoodRecords()).thenAnswer((_) async => records);
      when(repository.deleteFoodRecord('1')).thenAnswer((_) async {});

      await cubit.loadFoodRecords();
      await cubit.deleteFoodRecord('1');

      final state = cubit.state as RecordListLoaded;
      expect(state.records.length, 1);
      expect(state.records.single.id, '2');
      expect(state.filteredRecords.single.id, '2');
    });

    test('deleteFoodRecord emits RecordError then reloads when delete fails', () async {
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
      when(repository.deleteFoodRecord('1')).thenThrow(Exception('boom'));

      final states = <RecordState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadFoodRecords();
      await cubit.deleteFoodRecord('1');

      expect(states.any((s) => s is RecordError), isTrue);
      expect(cubit.state, isA<RecordListLoaded>());

      await sub.cancel();
    });
  });
}
