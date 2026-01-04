import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Result of a video-to-recipe analysis.
class VideoAnalysisResult {
  final String recipe;

  const VideoAnalysisResult({required this.recipe});
}

/// Uploads a cooking video to the server and returns a generated recipe.
///
/// Contract:
/// - POST {baseUrl}/upload-video/
/// - multipart/form-data field name: `file`
/// - response: {"recipe": "..."}
class VideoAnalysisService {
  // Mặc định trỏ tới server uvicorn đang chạy
  static const String defaultBaseUrl = 'http://192.168.1.140:8002';

  final http.Client _client;
  final String _baseUrl;

  VideoAnalysisService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = (baseUrl == null || baseUrl.isEmpty)
          ? defaultBaseUrl
          : baseUrl;

  /// Analyze a video from a local file path.
  Future<VideoAnalysisResult> analyzeVideo(
    String videoPath, {
    String? goal,
    String? allergy,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload-video/');
    final request = http.MultipartRequest('POST', uri);

    final file = await http.MultipartFile.fromPath('file', videoPath);
    request.files.add(file);

    if (goal != null) {
      request.fields['goal'] = goal;
    }
    if (allergy != null) {
      request.fields['allergy'] = allergy;
    }

    return _send(request);
  }

  /// Analyze a video from bytes (useful for tests).
  Future<VideoAnalysisResult> analyzeVideoBytes({
    required List<int> bytes,
    String filename = 'video.mp4',
    String? goal,
    String? allergy,
  }) async {
    final uri = Uri.parse('$_baseUrl/upload-video/');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );

    if (goal != null) {
      request.fields['goal'] = goal;
    }
    if (allergy != null) {
      request.fields['allergy'] = allergy;
    }

    return _send(request);
  }

  Future<VideoAnalysisResult> _send(http.MultipartRequest request) async {
    final uri = request.url;

    debugPrint('Sending video to $uri');

    final streamedResponse = await _client
        .send(request)
        .timeout(
          const Duration(seconds: 120),
          onTimeout: () {
            throw Exception(
              'Timeout when connecting to the video analysis server',
            );
          },
        );

    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Video analysis status: ${response.statusCode}');

    if (response.statusCode != 200) {
      throw Exception('API Error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final recipe = (data['recipe'] ?? '').toString().trim();
    if (recipe.isEmpty) {
      throw Exception('Không có công thức trả về từ server');
    }

    return VideoAnalysisResult(recipe: recipe);
  }
}
