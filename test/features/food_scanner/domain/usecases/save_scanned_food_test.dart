import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/domain/entities/scanned_food_entity.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/repositories/scanned_food_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/save_scanned_food.dart';

class FakeScannedFoodRepository implements ScannedFoodRepository {
  ScannedFoodEntity? saved;

  @override
  Future<void> saveScannedFood(ScannedFoodEntity food) async {
    saved = food;
  }
}

void main() {
  group('SaveScannedFood', () {
    test('creates entity and saves via repository', () async {
      final repo = FakeScannedFoodRepository();
      final usecase = SaveScannedFood(repo);

      final result = await usecase(
        imagePath: 'C:/tmp/scan.jpg',
        scanType: ScanType.food,
        isProcessed: true,
        foodName: 'Apple',
        calories: 52,
        description: 'Fresh',
        protein: 0.3,
        carbs: 14.0,
        fat: 0.2,
      );

      expect(repo.saved, isNotNull);

      expect(result.imagePath, 'C:/tmp/scan.jpg');
      expect(result.scanType, ScanType.food);
      expect(result.isProcessed, isTrue);
      expect(result.foodName, 'Apple');
      expect(result.calories, 52);
      expect(result.description, 'Fresh');
      expect(result.protein, closeTo(0.3, 1e-9));
      expect(result.carbs, closeTo(14.0, 1e-9));
      expect(result.fat, closeTo(0.2, 1e-9));

      // ID/date are generated; just sanity check
      expect(result.id, isNotNull);
      expect(result.id, isNotEmpty);
      expect(result.scanDate, isA<DateTime>());
    });
  });
}
