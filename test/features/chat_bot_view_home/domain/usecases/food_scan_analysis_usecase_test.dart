import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/food_scan_analysis_usecase.dart';
import 'package:diet_tracking_project/features/record_view_home/domain/entities/food_record_entity.dart';

void main() {
  group('BuildFoodScanAnalysisPromptUseCase', () {
    test('includes required product info', () {
      final useCase = BuildFoodScanAnalysisPromptUseCase();
      final record = FoodRecordEntity(
        foodName: 'Sữa chua',
        calories: 123,
        date: DateTime.utc(2025, 1, 2),
        recordType: RecordType.barcode,
      );

      final prompt = useCase.execute(record);

      expect(prompt, contains('Thông tin sản phẩm đã quét'));
      expect(prompt, contains('• Tên: Sữa chua'));
      expect(prompt, contains('• Calories: 123 kcal'));
    });

    test('conditionally includes macros/barcode/nutritionDetails when provided', () {
      final useCase = BuildFoodScanAnalysisPromptUseCase();
      final record = FoodRecordEntity(
        foodName: 'Bánh mì',
        calories: 250.4,
        protein: 10.2,
        carbs: 40.7,
        fat: 5.1,
        barcode: '8930000000000',
        nutritionDetails: 'Thành phần: bột mì, sữa, trứng',
        imagePath: 'http://example.com/img.jpg',
        date: DateTime.utc(2025, 6, 7),
        recordType: RecordType.food,
      );

      final prompt = useCase.execute(record);

      expect(prompt, contains('• Protein: 10 g'));
      expect(prompt, contains('• Carbs: 41 g'));
      expect(prompt, contains('• Fat: 5 g'));
      expect(prompt, contains('• Barcode: 8930000000000'));
      expect(prompt, contains('• Thông tin thành phần/dinh dưỡng thêm:'));
      expect(prompt, contains('Thành phần: bột mì, sữa, trứng'));
    });

    test('does not include optional fields when they are null/empty', () {
      final useCase = BuildFoodScanAnalysisPromptUseCase();
      final record = FoodRecordEntity(
        foodName: 'Nước lọc',
        calories: 0,
        barcode: '   ',
        nutritionDetails: '  ',
        date: DateTime.utc(2025, 6, 7),
        recordType: RecordType.food,
      );

      final prompt = useCase.execute(record);

      expect(prompt, isNot(contains('Protein:')));
      expect(prompt, isNot(contains('Carbs:')));
      expect(prompt, isNot(contains('Fat:')));
      expect(prompt, isNot(contains('Barcode:')));
      expect(prompt, isNot(contains('Thông tin thành phần/dinh dưỡng thêm:')));
    });
  });
}
