import 'dart:convert';

import 'package:diet_tracking_project/features/upload_video/services/video_analysis_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('VideoAnalysisService', () {
    test('parses recipe from server response', () async {
      final client = MockClient((request) async {
        // MultipartRequest uses a streamed request; http/testing gives us a BaseRequest.
        // We can still validate URL/method.
        expect(request.method, 'POST');
        expect(request.url.path, '/upload-video/');

        return http.Response(
          jsonEncode({'recipe': 'Bước 1: ...'}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = VideoAnalysisService(
        client: client,
        baseUrl: 'http://example.com',
      );

      final result = await service.analyzeVideoBytes(
        bytes: const [0, 1, 2, 3],
        filename: 'test.mp4',
      );

      expect(result.recipe, 'Bước 1: ...');
    });
  });
}
