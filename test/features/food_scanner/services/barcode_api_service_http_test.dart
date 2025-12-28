import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:diet_tracking_project/features/food_scanner/services/barcode_api_service.dart';

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

http.StreamedResponse streamedText(int statusCode, String body) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(Stream<List<int>>.value(bytes), statusCode);
}

void main() {
  group('BarcodeApiService (http injected)', () {
    test('getProductInfo returns parsed BarcodeProduct on 200', () async {
      final client = FakeHttpClient((req) {
        expect(req.method, 'POST');
        expect(req.url.path, '/get_product_info');

        return streamedJson(200, {
          'barcode': '123',
          'product': {
            'product_name': 'Chips',
            'brands': 'BrandX',
            'image_url': 'https://example.com/x.jpg',
            'ingredients_text': 'Potatoes, salt',
            'nutriments': {
              'energy-kcal': 250,
              'proteins': 3,
              'carbohydrates': 30,
              'fat': 12,
            },
          },
        });
      });

      final svc = BarcodeApiService(client: client);
      final product = await svc.getProductInfo('123');

      expect(product.barcode, '123');
      expect(product.productName, 'Chips');
      expect(product.brands, 'BrandX');
      expect(product.calories, 250);
      expect(product.protein, 3);
      expect(product.carbohydrates, 30);
      expect(product.fat, 12);
    });

    test('getProductInfo throws on non-200', () async {
      final client = FakeHttpClient((req) => streamedText(500, 'oops'));
      final svc = BarcodeApiService(client: client);

      await expectLater(
        () => svc.getProductInfo('123'),
        throwsA(
          predicate((e) => e.toString().contains('Server trả về lỗi')),
        ),
      );
    });

    test('getProductInfo wraps server error key', () async {
      final client = FakeHttpClient((req) => streamedJson(200, {'error': 'bad'}));
      final svc = BarcodeApiService(client: client);

      await expectLater(
        () => svc.getProductInfo('123'),
        throwsA(
          predicate((e) => e.toString().contains('Lỗi khi tra cứu sản phẩm')),
        ),
      );
    });

    test('getProductInfo throws friendly message on invalid JSON (FormatException)', () async {
      final client = FakeHttpClient((req) => streamedText(200, 'not-json'));
      final svc = BarcodeApiService(client: client);

      await expectLater(
        () => svc.getProductInfo('123'),
        throwsA(
          predicate((e) => e.toString().contains('Dữ liệu trả về từ server không hợp lệ')),
        ),
      );
    });

    test('getProductInfo throws friendly message on SocketException', () async {
      final client = FakeHttpClient((req) => throw const SocketException('no net'));
      final svc = BarcodeApiService(client: client);

      await expectLater(
        () => svc.getProductInfo('123'),
        throwsA(
          predicate((e) => e.toString().contains('Không thể kết nối đến server barcode')),
        ),
      );
    });

    test('scanBarcode parses BarcodeProduct from multipart response', () async {
      final dir = await Directory.systemTemp.createTemp('barcode_api_test_');
      addTearDown(() async {
        try {
          await dir.delete(recursive: true);
        } catch (_) {}
      });

      final file = File('${dir.path}/barcode.jpg');
      await file.writeAsBytes(const [1, 2, 3, 4]);

      final client = FakeHttpClient((req) {
        expect(req.method, 'POST');
        expect(req.url.path, '/scan_barcode');
        expect(req, isA<http.MultipartRequest>());

        return streamedJson(200, {
          'barcode': '999',
          'product': {
            'product_name': 'Milk',
            'brands': 'Dairy',
            'image_url': 'https://example.com/m.jpg',
            'ingredients_text': 'Milk',
            'nutriments': {
              'energy-kcal': 60,
              'proteins': 3.2,
              'carbohydrates': 4.8,
              'fat': 3.3,
            },
          },
        });
      });

      final svc = BarcodeApiService(client: client);
      final product = await svc.scanBarcode(file.path);

      expect(product.barcode, '999');
      expect(product.productName, 'Milk');
      expect(product.calories, 60);
    });
  });
}
