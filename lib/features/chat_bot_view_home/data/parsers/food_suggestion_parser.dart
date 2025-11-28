// Helper class for food suggestion data
class FoodSuggestion {
  final String foodName;
  final double calories;
  final String? reason; // Lý do chọn
  final String? nutritionDetails; // Khối "Thông tin dinh dưỡng"

  FoodSuggestion({
    required this.foodName,
    required this.calories,
    this.reason,
    this.nutritionDetails,
  });
}

class FoodSuggestionParser {
  // Extract multiple suggestions strictly by "Món ăn đề xuất|gợi ý: <tên>" blocks
  static List<FoodSuggestion> extract(String text) {
    final lower = text.toLowerCase();
    final hasSuggestKeyword =
        lower.contains('món ăn đề xuất') || lower.contains('món ăn gợi ý');
    if (!hasSuggestKeyword) return [];

    final nameRx = RegExp(
      r'(Món ăn (?:đề xuất|gợi ý)[:：]?\s*)(.+)',
      caseSensitive: false,
    );

    final matches = nameRx.allMatches(text).toList();
    if (matches.isEmpty) return [];

    final suggestions = <FoodSuggestion>[];

    for (var i = 0; i < matches.length; i++) {
      final m = matches[i];
      final name = (m.group(2) ?? '').trim();
      if (name.isEmpty) continue;

      // Lấy đoạn text từ sau tên đến trước tên tiếp theo để tìm calo
      final start = m.end;
      final end = i + 1 < matches.length ? matches[i + 1].start : text.length;
      final slice = text.substring(start, end);

      final caloRxList = <RegExp>[
        RegExp(
          r'Calo[:：]?\s*[~≈]?(\d+)\s*[-–]\s*(\d+)\s*kcal',
          caseSensitive: false,
        ),
        RegExp(
          r'Calo[:：]?\s*Khoảng\s*(\d+)\s*-\s*(\d+)\s*kcal',
          caseSensitive: false,
        ),
        RegExp(r'Calo[:：]?\s*(\d+)\s*kcal', caseSensitive: false),
      ];
      double calories = 0;
      for (final rx in caloRxList) {
        final cm = rx.firstMatch(slice);
        if (cm != null) {
          final c1 = double.tryParse(cm.group(1) ?? '') ?? 0;
          final c2 =
              double.tryParse(
                (cm.groupCount >= 2 ? cm.group(2) : null) ?? '',
              ) ??
              0;
          calories = (c1 > 0 && c2 > 0) ? (c1 + c2) / 2 : (c1 > 0 ? c1 : c2);
          break;
        }
      }

      // Tách lý do và thông tin dinh dưỡng bằng regex linh hoạt (hỗ trợ **...** và xuống dòng)
      String? reason;
      String? nutrition;
      final reasonMatch = RegExp(
        r'\*\*\s*Lý do chọn\s*[:：]?\s*\*\*\s*([\s\S]*?)(?:\n\s*\*\*|\$)',
        caseSensitive: false,
      ).firstMatch(slice);
      if (reasonMatch != null) {
        reason = reasonMatch.group(1)?.trim();
      }
      RegExp _nutriRx1 = RegExp(
        r'(?:\*\*)?\s*Thông tin dinh dưỡng(?:\s*\([^)]*\))?\s*(?:\*\*)?\s*[:：]?\s*([\s\S]*)',
        caseSensitive: false,
      );
      RegExp _nutriRx2 = RegExp(
        r'(?:\*\*)?\s*Th\w*ng tin dinh d\w*(?:\s*\([^)]*\))?\s*(?:\*\*)?\s*[:：]?\s*([\s\S]*)',
        caseSensitive: false,
      );
      final nutritionMatch =
          _nutriRx1.firstMatch(slice) ?? _nutriRx2.firstMatch(slice);
      if (nutritionMatch != null) {
        nutrition = nutritionMatch.group(1)?.trim();
      }
      // Làm sạch ký tự ngôi sao trong nội dung dinh dưỡng, bỏ các dòng chỉ có sao
      if (nutrition != null) {
        final cleanedLines = nutrition
            .split('\n')
            .map((l) => l.replaceAll('⭐', '').trimRight())
            .where((l) => l.trim().isNotEmpty)
            .toList();
        nutrition = cleanedLines.join('\n');
      }
      // Fallback: nếu chưa bắt được, tách theo dòng sau tiêu đề và gom các dòng bullet
      if (nutrition == null || nutrition.trim().isEmpty) {
        final lines = slice.split('\n');
        bool inSection = false;
        final buff = <String>[];
        for (final raw in lines) {
          final l = raw.trimRight();
          final lower = l.toLowerCase();
          if (!inSection && lower.contains('thông tin dinh dưỡng')) {
            inSection = true;
            continue;
          }
          if (!inSection) continue;
          // Dừng khi gặp header mới hoặc dòng toàn '**'
          if (l.startsWith('**')) break;
          if (l.trim().isEmpty) continue;
          // Fallback 2: gom các dòng bullet thường gặp nếu vẫn chưa có
          if (nutrition == null || nutrition.trim().isEmpty) {
            final lines = slice.split('\n');
            bool afterHeader = false;
            final buff = <String>[];
            for (final raw in lines) {
              final l = raw.trimRight();
              final lower = l.toLowerCase();
              if (!afterHeader && lower.contains('thông tin dinh dưỡng')) {
                afterHeader = true;
                continue;
              }
              if (!afterHeader) continue;
              if (l.startsWith('**') || l.startsWith('⭐'))
                break; // kết thúc block
              if (l.trim().isEmpty) continue;
              final isBullet =
                  l.trimLeft().startsWith('-') ||
                  l.trimLeft().startsWith('•') ||
                  lower.contains('kcal') ||
                  lower.contains('protein') ||
                  lower.contains('carb') ||
                  lower.contains('fat');
              if (isBullet) buff.add(l);
            }
            if (buff.isNotEmpty) nutrition = buff.join('\n');
          }

          buff.add(l);
        }
        if (buff.isNotEmpty) {
          nutrition = buff.join('\n');
        }
      }

      // Chỉ thêm theo tên món; không thêm các block “Lý do chọn”, “Thông tin dinh dưỡng” vào tên
      final cleanedName = name.replaceAll(RegExp(r'\*\*'), '').trim();
      final ignoreLower = cleanedName.toLowerCase();
      if (ignoreLower.contains('thông tin dinh dưỡng') ||
          ignoreLower.contains('lý do chọn')) {
        continue;
      }

      final exists = suggestions.any(
        (e) => e.foodName.toLowerCase() == cleanedName.toLowerCase(),
      );
      if (!exists) {
        suggestions.add(
          FoodSuggestion(
            foodName: cleanedName,
            calories: calories,
            reason: reason,
            nutritionDetails: nutrition,
          ),
        );
      }
    }

    return suggestions;
  }
}

