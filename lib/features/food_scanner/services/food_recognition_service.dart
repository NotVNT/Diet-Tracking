import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Simple food recognition service interface and default stub implementation.
///
/// You can replace the stub with a real on-device model or call your API.
class FoodRecognitionResult {
  final String name;

  /// Backward-compatible: average calories if available.
  final double? calories;

  /// Preferred: calorie range estimate (min, max).
  final List<int>? caloriesRange;
  final String? description;
  final double? protein;
  final double? carbs;
  final double? fat;

  FoodRecognitionResult({
    required this.name,
    this.calories,
    this.caloriesRange,
    this.description,
    this.protein,
    this.carbs,
    this.fat,
  });
}

class FoodRecognitionService {
  // Server đang chạy tại máy có IP: 192.168.1.140
  // Máy tính và điện thoại phải cùng mạng WiFi
  static const String defaultBaseUrl = 'http://192.168.1.140:8000';

  final http.Client _client;
  final String _baseUrl;

  FoodRecognitionService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl == null || baseUrl.isEmpty)
          ? defaultBaseUrl
          : baseUrl;

  /// Recognize food from an image path. Return null if not recognized.
  Future<FoodRecognitionResult?> recognizeFood(String imagePath) async {
    try {
      final uri = Uri.parse('$_baseUrl/scan_food');
      final request = http.MultipartRequest('POST', uri);

      // Attach file ảnh
      final file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      // Gửi request
      debugPrint('Sending image to $uri');
      final streamedResponse = await _client
          .send(request)
          .timeout(
            const Duration(
              seconds: 20,
            ), // Tăng timeout cho việc upload và xử lý AI
            onTimeout: () {
              throw Exception(
                'Timeout when connecting to the food recognition server',
              );
            },
          );

      // Đọc response
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // Server sometimes omits or malforms dish_name, so ignore it to avoid crashes.
        const fallbackName = 'Thông tin món ăn';

        // Preferred: {"calories_range": [min, max] | null}
        final dynamic rangeRaw = jsonData['calories_range'];

        List<int>? range;
        if (rangeRaw is List && rangeRaw.length == 2) {
          final a = rangeRaw[0];
          final b = rangeRaw[1];

          int? n1;
          int? n2;
          if (a is num) n1 = a.round();
          if (b is num) n2 = b.round();
          if (n1 == null && a is String) n1 = num.tryParse(a)?.round();
          if (n2 == null && b is String) n2 = num.tryParse(b)?.round();

          if (n1 != null && n2 != null) {
            range = [n1, n2];
          }
        }

        double? avg;
        if (range != null) {
          avg = (range[0] + range[1]) / 2.0;
        }

        if (range == null) {
          debugPrint(
            'calories_range not found or invalid in response; still returning fallback result',
          );
        }

        return FoodRecognitionResult(
          name: fallbackName,
          calories: avg,
          caloriesRange: range,
          description: null,
        );
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error in recognizeFood: $e');
      return null;
    }
  }
}
