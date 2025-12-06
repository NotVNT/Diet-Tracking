import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../data/models/food_scanner_models.dart';

class BarcodeApiService {
  static const String baseUrl = 'http://192.168.1.140:8000';

  Future<BarcodeProduct> getProductInfo(
    String barcodeValue, {
    Map<String, dynamic>? userData,
  }) async {
    try {
      debugPrint('🔵 [API] Gửi barcode lên server: $barcodeValue');
      if (userData != null) {
        debugPrint('🟣 [API] Gửi kèm user data: ${userData.toString()}');
      }

      final uri = Uri.parse('$baseUrl/get_product_info');

      final Map<String, String> body = {'barcode': barcodeValue};
      if (userData != null) {
        void putNum(String key, dynamic v) {
          if (v != null) body[key] = v.toString();
        }

        void putStr(String key, dynamic v) {
          if (v != null && v.toString().isNotEmpty) body[key] = v.toString();
        }

        putNum('age', userData['age']);
        putNum('height', userData['height']);
        putNum('weight', userData['weight']);
        final gw = userData.containsKey('goal_weight')
            ? userData['goal_weight']
            : userData['goalWeightKg'];
        putNum('goal_weight', gw);
        putStr('disease', userData['disease']);
        putStr('allergy', userData['allergy']);
        putStr('goal', userData['goal']);
        putStr('gender', userData['gender']);
      }

      final response = await http
          .post(uri, body: body)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout khi kết nối server barcode');
            },
          );

      debugPrint('🔵 [API] Status Code: ${response.statusCode}');
      debugPrint('🔵 [API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        debugPrint('🔵 [API] JSON Keys: ${jsonData.keys.toList()}');
        debugPrint('🔵 [API] Barcode: ${jsonData['barcode']}');
        debugPrint('🔵 [API] Product is null: ${jsonData['product'] == null}');

        if (jsonData.containsKey('error')) {
          throw Exception(jsonData['error'] as String);
        }

        if (jsonData['product'] == null) {
          throw Exception(
            'Không tìm thấy sản phẩm trong database OpenFoodFacts',
          );
        }

        final product = BarcodeProduct.fromJson(jsonData);
        debugPrint('🟢 [API] Parsed Product Name: ${product.productName}');
        debugPrint('🟢 [API] Parsed Calories: ${product.calories}');

        return product;
      } else {
        throw Exception(
          'Server trả về lỗi: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến server barcode. '
        'Vui lòng kiểm tra server đang chạy tại $baseUrl',
      );
    } on FormatException {
      throw Exception('Dữ liệu trả về từ server không hợp lệ');
    } catch (e) {
      throw Exception('Lỗi khi tra cứu sản phẩm: $e');
    }
  }

  Future<BarcodeProduct> scanBarcode(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/scan_barcode');
      final request = http.MultipartRequest('POST', uri);

      final file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout khi kết nối server barcode');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('🔵 [API] Status Code: ${response.statusCode}');
      debugPrint('🔵 [API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        debugPrint('🔵 [API] JSON Keys: ${jsonData.keys.toList()}');
        debugPrint('🔵 [API] Barcode: ${jsonData['barcode']}');
        debugPrint('🔵 [API] Product is null: ${jsonData['product'] == null}');

        if (jsonData.containsKey('error')) {
          throw Exception(jsonData['error'] as String);
        }

        final product = BarcodeProduct.fromJson(jsonData);
        debugPrint('🟢 [API] Parsed Product Name: ${product.productName}');
        debugPrint('🟢 [API] Parsed Calories: ${product.calories}');

        return product;
      } else {
        throw Exception(
          'Server trả về lỗi: ${response.statusCode} - ${response.body}',
        );
      }
    } on SocketException {
      throw Exception(
        'Không thể kết nối đến server barcode. '
        'Vui lòng kiểm tra server đang chạy tại $baseUrl',
      );
    } on FormatException {
      throw Exception('Dữ liệu trả về từ server không hợp lệ');
    } catch (e) {
      throw Exception('Lỗi khi quét barcode: $e');
    }
  }

  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/docs'), headers: {'Accept': 'text/html'})
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
