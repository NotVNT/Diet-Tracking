import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/usecases/generate_food_suggestion_usecase.dart';

void main() {
  group('GenerateFoodSuggestionUseCase', () {
    test('includes ingredients, budget, and mealType in the prompt', () {
      final useCase = GenerateFoodSuggestionUseCase();

      final prompt = useCase.execute(
        ingredients: 'trứng, cơm, cà chua',
        budget: '50',
        mealType: 'bữa sáng',
      );

      expect(prompt, contains('trứng, cơm, cà chua'));
      expect(prompt, contains('Với chi phí là: 50k'));
      expect(prompt, contains('cho bữa sáng'));
    });
  });
}
