import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:diet_tracking_project/features/food_scanner/services/food_recognition_service.dart';

class FakeHttpClient extends http.BaseClient {
  final FutureOr<http.StreamedResponse> Function(http.BaseRequest request) handler;

  FakeHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final result = handler(request);
    return result is Future<http.StreamedResponse> ? await result : result;
  }
}

http.StreamedResponse streamedJson(int statusCode, Map<String, dynamic> jsonBody) {
  final bytes = utf8.encode(json.encode(jsonBody));
  return http.StreamedResponse(Stream<List<int>>.value(bytes), statusCode, headers: {
    'content-type': 'application/json',
  });
}

void main() {
  group('FoodRecognitionService (http injected)', () {
    test('returns FoodRecognitionResult when 200 and predictions present', () async {
      final dir = await Directory.systemTemp.createTemp('food_recognition_test_');
      addTearDown(() async {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/food.jpg');
      await file.writeAsBytes(const [1, 2, 3]);

      final client = FakeHttpClient((req) {
        expect(req.method, 'POST');
        expect(req.url.path, '/scan_food');
        expect(req, isA<http.MultipartRequest>());

        return streamedJson(200, {
          'predictions': {
            'total_calories': 100,
            'total_protein': 10,
            'total_carb': 20,
            'total_fat': 5,
          }
        });
      });

      final svc = FoodRecognitionService(client: client, baseUrl: 'http://test');
  final result = await svc.recognizeFood(file.path);

      expect(result, isNotNull);
      expect(result!.calories, 100);
      expect(result.protein, 10);
      expect(result.carbs, 20);
      expect(result.fat, 5);
      expect(result.description, isNotEmpty);
    });

    test('returns null when predictions missing', () async {
      final dir = await Directory.systemTemp.createTemp('food_recognition_test_');
      addTearDown(() async {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/food.jpg');
      await file.writeAsBytes(const [1, 2, 3]);

      final client = FakeHttpClient((req) => streamedJson(200, {'foo': 1}));
      final svc = FoodRecognitionService(client: client, baseUrl: 'http://test');

      final result = await svc.recognizeFood(file.path);
      expect(result, isNull);
    });

    test('returns null when statusCode != 200', () async {
      final dir = await Directory.systemTemp.createTemp('food_recognition_test_');
      addTearDown(() async {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/food.jpg');
      await file.writeAsBytes(const [1, 2, 3]);

      final client = FakeHttpClient((req) => http.StreamedResponse(const Stream.empty(), 500));
      final svc = FoodRecognitionService(client: client, baseUrl: 'http://test');

      final result = await svc.recognizeFood(file.path);
      expect(result, isNull);
    });

    test('returns null when client throws', () async {
      final dir = await Directory.systemTemp.createTemp('food_recognition_test_');
      addTearDown(() async {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      });
      final file = File('${dir.path}/food.jpg');
      await file.writeAsBytes(const [1, 2, 3]);

      final client = FakeHttpClient((req) => throw Exception('boom'));
      final svc = FoodRecognitionService(client: client, baseUrl: 'http://test');

      final result = await svc.recognizeFood(file.path);
      expect(result, isNull);
    });
  });
}
