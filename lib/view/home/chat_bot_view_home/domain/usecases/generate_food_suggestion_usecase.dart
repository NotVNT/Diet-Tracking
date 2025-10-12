import 'dart:math';

/// Use case for generating food suggestion prompts
class GenerateFoodSuggestionUseCase {
  static const List<String> _pretextsBegin = [
    'Với nguyên liệu có sẵn như: ',
    'Hãy tạo món ăn với nguyên liệu có sẵn như sau: ',
    'Với nguyên liệu bao gồm: ',
    'Từ các nguyên liệu có sẵn: ',
  ];

  static const List<String> _pretextsMid = [
    "Tạo ra món ăn phù hợp với tôi, ",
    "Đề xuất món ăn phù hợp từ các nguyên liệu trên, ",
    "Hãy nghĩ ra một món ăn sử dụng toàn bộ nguyên liệu sau, ",
    "Lên thực đơn món ăn phù hợp với tôi, ",
  ];

  static const List<String> _pretextsEnd = [
    "cho tôi xem công thức đầy đủ. ",
    "hiện công thức đầy đủ của món ăn. ",
    "cho xem công thức nấu ăn đầy đủ. ",
    "cho biết công thức đầy đủ của món ăn. ",
  ];

  /// Generate food suggestion prompt
  String execute({
    required String ingredients,
    required String budget,
    required String mealType,
  }) {
    final random = Random();

    final randomPreTextBegin = _pretextsBegin[random.nextInt(_pretextsBegin.length)];
    final randomPreTextMid = _pretextsMid[random.nextInt(_pretextsMid.length)];
    final randomPreTextEnd = _pretextsEnd[random.nextInt(_pretextsEnd.length)];

    final budgetText = "Với chi phí là: ${budget}k";

    return '$randomPreTextBegin $ingredients. $randomPreTextMid $randomPreTextEnd $budgetText cho $mealType';
  }
}
