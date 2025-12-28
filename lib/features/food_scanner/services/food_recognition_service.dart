import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Simple food recognition service interface and default stub implementation.
///
/// You can replace the stub with a real on-device model or call your API.
class FoodRecognitionResult {
  final String name;
  final double? calories;
  final String? description;
  final double? protein;
  final double? carbs;
  final double? fat;

  FoodRecognitionResult({
    required this.name,
    this.calories,
    this.description,
    this.protein,
    this.carbs,
    this.fat,
  });
}

class FoodRecognitionService {
  // Server đang chạy tại máy có IP: 192.168.1.140
  // Máy tính và điện thoại phải cùng mạng WiFi
  static const String defaultBaseUrl = 'http://192.168.2.1:8000';

  final http.Client _client;
  final String _baseUrl;

  FoodRecognitionService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl == null || baseUrl.isEmpty) ? defaultBaseUrl : baseUrl;

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
      final streamedResponse = await _client.send(request).timeout(
        const Duration(seconds: 20), // Tăng timeout cho việc upload và xử lý AI
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
        final predictions = jsonData['predictions'] as Map<String, dynamic>?;

        if (predictions == null) {
          debugPrint('Predictions key not found in response');
          return null;
        }

        return FoodRecognitionResult(
          name: 'Thông tin món ăn', // Tên tạm thời
          calories: (predictions['total_calories'] as num?)?.toDouble(),
          protein: (predictions['total_protein'] as num?)?.toDouble(),
          carbs: (predictions['total_carb'] as num?)?.toDouble(),
          fat: (predictions['total_fat'] as num?)?.toDouble(),
          // Cung cấp một mô tả ngắn gọn, chung chung
          description: 'Thông tin dinh dưỡng được phân tích từ ảnh.',
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
