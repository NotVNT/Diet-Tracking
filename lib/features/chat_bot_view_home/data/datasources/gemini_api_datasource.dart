import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Datasource for Gemini API communication
class GeminiApiDatasource {
  /// Send message to Gemini API and get response
  Future<String> sendMessage(
    String prompt,
    Map<String, dynamic> contextData,
  ) async {
    try {
      // Automatically detect platform and use appropriate URL
      String baseUrl;
      if (kIsWeb) {
        // Web platform - use localhost
        baseUrl = 'http://127.0.0.1:8000';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        // Android emulator - use special IP to access host machine
        baseUrl = 'http://10.0.2.2:8000';
      } else {
        // iOS simulator or other platforms - use localhost
        baseUrl = 'http://127.0.0.1:8000';
      }

      final url = Uri.parse('$baseUrl/chat');
      // Prepare the API body from the context data
      final Map<String, dynamic> body = Map.from(contextData);
      body['prompt'] = prompt;

      // Ensure compatibility with the API's expected field names
      if (body.containsKey('goalWeightKg')) {
        body['goal_weight'] = body['goalWeightKg'] ?? 0.0;
        body.remove('goalWeightKg');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? 'Không có phản hồi từ AI';
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối API: ${e.toString()}');
    }
  }
}
