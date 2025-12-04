import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/models/food_scanner_models.dart';

/// Service để gọi API Python barcode scanner
class BarcodeApiService {
  // Server đang chạy tại máy có IP: 192.168.1.140
  // Máy tính và điện thoại phải cùng mạng WiFi
  static const String baseUrl = 'http://192.168.1.140:8000';

  // Ghi chú:
  // - Máy thật: Dùng IP máy tính (192.168.1.140)
  // - Emulator Android: Dùng 10.0.2.2
  // - Simulator iOS: Dùng 127.0.0.1

  /// Gửi mã barcode trực tiếp lên server (đã quét bằng ML Kit)
  ///
  /// [barcodeValue] - Mã barcode đã quét được
  /// [userData] - Thông tin người dùng (tùy chọn) để server cá nhân hóa
  /// Returns [BarcodeProduct] nếu thành công
  /// Throws [Exception] nếu có lỗi
  Future<BarcodeProduct> getProductInfo(
    String barcodeValue, {
    Map<String, dynamic>? userData,
  }) async {
    try {
      print('🔵 [API] Gửi barcode lên server: $barcodeValue');
      if (userData != null) {
        print('🟣 [API] Gửi kèm user data: ' + userData.toString());
      }

      final uri = Uri.parse('$baseUrl/get_product_info');

      // Chuẩn bị body form-url-encoded
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
        // Chấp nhận cả goalWeightKg hoặc goal_weight
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

      print('🔵 [API] Status Code: ${response.statusCode}');
      print('🔵 [API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        print('🔵 [API] JSON Keys: ${jsonData.keys.toList()}');
        print('🔵 [API] Barcode: ${jsonData['barcode']}');
        print('🔵 [API] Product is null: ${jsonData['product'] == null}');

        // Kiểm tra có lỗi từ server không
        if (jsonData.containsKey('error')) {
          throw Exception(jsonData['error'] as String);
        }

        // Kiểm tra product có null không
        if (jsonData['product'] == null) {
          throw Exception(
            'Không tìm thấy sản phẩm trong database OpenFoodFacts',
          );
        }

        // Parse thành BarcodeProduct
        final product = BarcodeProduct.fromJson(jsonData);
        print('🟢 [API] Parsed Product Name: ${product.productName}');
        print('🟢 [API] Parsed Calories: ${product.calories}');

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

  /// Gửi ảnh chứa barcode lên server và nhận thông tin sản phẩm
  /// (Legacy method - dùng pyzbar decode ảnh trên server)
  ///
  /// [imagePath] - Đường dẫn file ảnh chụp được
  /// Returns [BarcodeProduct] nếu thành công
  /// Throws [Exception] nếu có lỗi
  Future<BarcodeProduct> scanBarcode(String imagePath) async {
    try {
      final uri = Uri.parse('$baseUrl/scan_barcode');
      final request = http.MultipartRequest('POST', uri);

      // Attach file ảnh
      final file = await http.MultipartFile.fromPath('file', imagePath);
      request.files.add(file);

      // Gửi request
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout khi kết nối server barcode');
        },
      );

      // Đọc response
      final response = await http.Response.fromStream(streamedResponse);

      print('🔵 [API] Status Code: ${response.statusCode}');
      print('🔵 [API] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        print('🔵 [API] JSON Keys: ${jsonData.keys.toList()}');
        print('🔵 [API] Barcode: ${jsonData['barcode']}');
        print('🔵 [API] Product is null: ${jsonData['product'] == null}');

        // Kiểm tra có lỗi từ server không
        if (jsonData.containsKey('error')) {
          throw Exception(jsonData['error'] as String);
        }

        // Parse thành BarcodeProduct
        final product = BarcodeProduct.fromJson(jsonData);
        print('🟢 [API] Parsed Product Name: ${product.productName}');
        print('🟢 [API] Parsed Calories: ${product.calories}');

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

  /// Test kết nối đến server
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
