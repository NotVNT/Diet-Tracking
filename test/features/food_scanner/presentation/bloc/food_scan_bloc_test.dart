import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/repositories/scanned_food_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/save_scanned_food.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_bloc.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_event.dart';
import 'package:diet_tracking_project/features/food_scanner/presentation/bloc/food_scan/food_scan_state.dart';
import 'package:diet_tracking_project/features/food_scanner/services/food_recognition_service.dart';

class FakeScannedFoodRepository implements ScannedFoodRepository {
  final List<ScannedFoodEntity> saved = [];

  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {
    saved.add(food);
  }
}

class FakeFoodRecognitionService extends FoodRecognitionService {
  FoodRecognitionResult? result;
  Object? error;

  @override
  Future<FoodRecognitionResult?> recognizeFood(String imagePath) async {
    final e = error;
    if (e != null) {
      throw e;
    }
    return result;
  }
}

void main() {
  group('FoodScanBloc', () {
    test('initial state is FoodScanInitial', () {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService();

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      expect(bloc.state, isA<FoodScanInitial>());
    });

    test('FoodScanRequested emits uploading then success and saves entity', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService()
        ..result = FoodRecognitionResult(
          name: 'Apple',
          calories: 52,
          description: 'Fresh apple',
          protein: 0.3,
          carbs: 14,
          fat: 0.2,
        );

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FoodScanUploading>(),
          predicate<FoodScanState>(
            (s) => s is FoodScanSuccess && s.message.contains('Apple'),
            'FoodScanSuccess containing food name',
          ),
        ]),
      );

      bloc.add(const FoodScanRequested(imagePath: '/tmp/food.jpg'));

      await states;
      expect(repo.saved, isNotEmpty);
      expect(repo.saved.single.scanType, ScanType.food);
      expect(repo.saved.single.imagePath, '/tmp/food.jpg');
      expect(repo.saved.single.foodName, 'Apple');
      expect(repo.saved.single.calories, 52);
    });

    test('FoodScanRequested emits error when recognition throws', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService()..error = Exception('boom');

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FoodScanUploading>(),
          predicate<FoodScanState>(
            (s) => s is FoodScanError && s.message.isNotEmpty,
            'FoodScanError',
          ),
        ]),
      );

      bloc.add(const FoodScanRequested(imagePath: '/tmp/food.jpg'));
      await states;
      expect(repo.saved, isEmpty);
    });

    test('CallFoodRecognitionAPIEvent emits uploading then FoodRecognitionAPICalledState', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService()
        ..result = FoodRecognitionResult(
          name: 'Noodles',
          calories: 300,
          description: 'Noodle soup',
        );

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FoodScanUploading>(),
          predicate<FoodScanState>(
            (s) => s is FoodRecognitionAPICalledState && s.foodName == 'Noodles' && s.calories == 300,
            'FoodRecognitionAPICalledState with values',
          ),
        ]),
      );

      bloc.add(const CallFoodRecognitionAPIEvent(imagePath: '/tmp/food.jpg'));
      await states;
    });

    test('BuildDescriptionEvent emits DescriptionBuiltState with formatted text', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService();

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emits(
          predicate<FoodScanState>(
            (s) =>
                s is DescriptionBuiltState &&
                s.description.contains('Calories') &&
                s.description.contains('Tasty'),
            'DescriptionBuiltState containing calories + recognition text',
          ),
        ),
      );

      bloc.add(const BuildDescriptionEvent(calories: 123, recognitionDescription: 'Tasty'));
      await states;
    });

    test('SaveScannedFoodEvent emits uploading then success', () async {
      final repo = FakeScannedFoodRepository();
      final save = SaveScannedFood(repo);
      final service = FakeFoodRecognitionService();

      final bloc = FoodScanBloc(saveScannedFood: save, foodRecognitionService: service);
      addTearDown(bloc.close);

      final states = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<FoodScanUploading>(),
          isA<FoodScanSuccess>(),
        ]),
      );

      bloc.add(
        const SaveScannedFoodEvent(
          imagePath: '/tmp/food.jpg',
          foodName: 'Soup',
          calories: 100,
          description: 'Hot soup',
        ),
      );

      await states;
      expect(repo.saved, isNotEmpty);
      expect(repo.saved.single.scanType, ScanType.food);
    });
  });
}
