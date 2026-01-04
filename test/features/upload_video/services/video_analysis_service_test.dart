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

    test('throws when server responds with non-200', () async {
      final client = MockClient((request) async {
        return http.Response('oops', 500);
      });

      final service = VideoAnalysisService(
        client: client,
        baseUrl: 'http://example.com',
      );

      expect(
        () => service.analyzeVideoBytes(bytes: const [1, 2, 3]),
        throwsA(
          predicate((e) => e.toString().contains('API Error: 500')),
        ),
      );
    });

    test('throws when response is not valid JSON', () async {
      final client = MockClient((request) async {
        return http.Response(
          'not-json',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = VideoAnalysisService(
        client: client,
        baseUrl: 'http://example.com',
      );

      expect(
        () => service.analyzeVideoBytes(bytes: const [1, 2, 3]),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when response JSON is not a map', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode([1, 2, 3]),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = VideoAnalysisService(
        client: client,
        baseUrl: 'http://example.com',
      );

      expect(
        () => service.analyzeVideoBytes(bytes: const [1, 2, 3]),
        throwsA(predicate((e) => e.toString().contains('Invalid response format'))),
      );
    });

    test('throws when recipe is empty', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'recipe': '   '}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = VideoAnalysisService(
        client: client,
        baseUrl: 'http://example.com',
      );

      expect(
        () => service.analyzeVideoBytes(bytes: const [1, 2, 3]),
        throwsA(
          predicate((e) => e.toString().contains('Không có công thức')),
        ),
      );
    });
  });
}
