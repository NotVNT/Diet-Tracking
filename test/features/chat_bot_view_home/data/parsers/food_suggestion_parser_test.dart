import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/data/parsers/food_suggestion_parser.dart';

void main() {
  group('FoodSuggestionParser', () {
    test('returns empty list when missing suggestion keyword', () {
      final suggestions = FoodSuggestionParser.extract('Hello world');
      expect(suggestions, isEmpty);
    });

    test('extracts single suggestion name + calories (single value)', () {
      const text = '''
Món ăn gợi ý: Cơm gà
Calo: 500 kcal
''';
      final suggestions = FoodSuggestionParser.extract(text);
      expect(suggestions.length, 1);
      expect(suggestions.first.foodName, 'Cơm gà');
      expect(suggestions.first.calories, 500);
    });

    test('extracts calories average from range', () {
      const text = '''
Món ăn đề xuất: Salad ức gà
Calo: 300 - 500 kcal
''';
      final suggestions = FoodSuggestionParser.extract(text);
      expect(suggestions.length, 1);
      expect(suggestions.first.foodName, 'Salad ức gà');
      expect(suggestions.first.calories, 400);
    });

    test('extracts reason and nutrition section and cleans star bullets', () {
      const text = '''
Món ăn đề xuất: Bún bò
Calo: 650 kcal
**Lý do chọn:**
- Dễ ăn
- Nhiều protein
**Thông tin dinh dưỡng:**
⭐ Protein: 30g
⭐ Carbs: 70g
⭐ Fat: 20g
''';
      final suggestions = FoodSuggestionParser.extract(text);
      expect(suggestions.length, 1);
      final s = suggestions.first;
      expect(s.reason, contains('Dễ ăn'));
      expect(s.nutritionDetails, isNotNull);
      expect(s.nutritionDetails, contains('Protein: 30g'));
      expect(s.nutritionDetails, isNot(contains('⭐')));
    });

    test('deduplicates by foodName case-insensitively', () {
      const text = '''
Món ăn đề xuất: Pho
Calo: 400 kcal
Món ăn gợi ý: pho
Calo: 450 kcal
''';
      final suggestions = FoodSuggestionParser.extract(text);
      expect(suggestions.length, 1);
      expect(suggestions.first.foodName.toLowerCase(), 'pho');
    });
  });
}
