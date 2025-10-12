import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_data_model.dart';

/// Datasource for Gemini API communication
class GeminiApiDatasource {
  /// Send message to Gemini API and get response
  Future<String> sendMessage(String prompt, UserDataModel userData) async {
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
      final body = userData.toApiBody(prompt);

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
