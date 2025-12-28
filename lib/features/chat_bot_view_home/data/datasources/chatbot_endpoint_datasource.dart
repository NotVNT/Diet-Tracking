import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

const String _defaultBaseUrl = '';
const String _overrideBaseUrl = String.fromEnvironment(
  'CHATBOT_API_BASE_URL',
  defaultValue: '',
);
const bool _useEmulatorHost = bool.fromEnvironment(
  'CHATBOT_USE_EMULATOR_HOST',
  defaultValue: false,
);

/// Datasource for Gemini API communication
class GeminiApiDatasource {
  /// Send message to Gemini API and get response
  Future<String> sendMessage(
    String prompt,
    Map<String, dynamic> contextData,
  ) async {
    try {
      final baseUrl = _resolveBaseUrl();

      final url = Uri.parse('$baseUrl/chat');
      // Prepare the API body from the context data
      final Map<String, dynamic> body = Map.from(contextData);

      // If this looks like a food-scan analysis prompt, prepend concise user context
      final String finalPrompt = _shouldAttachUserContext(prompt)
          ? _composePromptWithUserContext(prompt, body)
          : prompt;

      body['prompt'] = finalPrompt;

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

  bool _shouldAttachUserContext(String prompt) {
    // Only attach context for the dedicated food-scan analysis prompts
    return prompt.contains('Bạn là chuyên gia dinh dưỡng cá nhân');
  }

  String _composePromptWithUserContext(
    String prompt,
    Map<String, dynamic> ctx,
  ) {
    final b = StringBuffer();
    // Build compact user profile preamble
    final age = ctx['age'];
    final gender = ctx['gender'];
    final height = ctx['height'];
    final weight = ctx['weight'];
    final goal = ctx['goal'];
    final disease = (ctx['disease'] ?? '').toString();
    final allergy = (ctx['allergy'] ?? '').toString();
    final goalWeight = ctx['goal_weight'] ?? ctx['goalWeightKg'];

    b.writeln('Bối cảnh người dùng (tóm tắt, dùng để cá nhân hoá):');
    b.writeln('- Tuổi: ${age ?? 'N/A'}');
    b.writeln('- Giới tính: ${gender ?? 'N/A'}');
    b.writeln('- Chiều cao: ${height ?? 'N/A'} cm');
    b.writeln('- Cân nặng: ${weight ?? 'N/A'} kg');
    b.writeln('- Mục tiêu: ${goal ?? 'N/A'}');
    if (goalWeight != null) b.writeln('- Cân nặng mục tiêu: $goalWeight kg');
    if (disease.isNotEmpty) b.writeln('- Bệnh lý: $disease');
    if (allergy.isNotEmpty) b.writeln('- Dị ứng: $allergy');
    b.writeln('---');
    b.write(prompt);

    return b.toString();
  }
}

String _resolveBaseUrl() {
  if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;

  if (_useEmulatorHost &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:8000';
  }

  return _defaultBaseUrl;
}
