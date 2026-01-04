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
    test('returns FoodRecognitionResult when 200 and calories_range present', () async {
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
          'calories_range': [90, 110],
        });
      });

      final svc = FoodRecognitionService(client: client, baseUrl: 'http://test');
      final result = await svc.recognizeFood(file.path);

      expect(result, isNotNull);
      expect(result!.caloriesRange, [90, 110]);
      expect(result.calories, 100);
      expect(result.protein, isNull);
      expect(result.carbs, isNull);
      expect(result.fat, isNull);
      // Description is optional UI text; current implementation may include
      // the range as a fallback.
      expect(result.description, anyOf(isNull, isNotEmpty));
    });

  test('still returns result when calories_range missing', () async {
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
      expect(result, isNotNull);
      expect(result!.caloriesRange, isNull);
      expect(result.calories, isNull);
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
