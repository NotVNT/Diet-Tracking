import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/chat_bot_view_home/domain/entities/user_data_entity.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/domain/repositories/user_repository.dart';
import 'package:diet_tracking_project/features/food_scanner/data/models/food_scanner_models.dart';
import 'package:diet_tracking_project/features/food_scanner/domain/usecases/get_barcode_product_info.dart';
import 'package:diet_tracking_project/features/food_scanner/services/barcode_api_service.dart';
import 'package:diet_tracking_project/model/nutrition_calculation_model.dart';

class FakeBarcodeApiService implements BarcodeApiService {
  String? lastBarcode;
  Map<String, dynamic>? lastUserData;
  late BarcodeProduct response;

  @override
  Future<BarcodeProduct> getProductInfo(
    String barcodeValue, {
    Map<String, dynamic>? userData,
  }) async {
    lastBarcode = barcodeValue;
    lastUserData = userData;
    return response;
  }

  @override
  Future<BarcodeProduct> scanBarcode(String imagePath) {
    throw UnimplementedError();
  }

  @override
  Future<bool> checkConnection() {
    throw UnimplementedError();
  }
}

class FakeUserRepository implements UserRepository {
  UserDataEntity? user;
  Object? throwOnGet;

  @override
  Future<UserDataEntity?> getCurrentUserData() async {
    if (throwOnGet != null) throw throwOnGet!;
    return user;
  }

  @override
  Future<bool> isUserAuthenticated() {
    throw UnimplementedError();
  }

  @override
  Future<String?> getCurrentUserId() {
    throw UnimplementedError();
  }

  @override
  Future<NutritionCalculation?> getNutritionPlan() {
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getRecentFoodRecords() {
    throw UnimplementedError();
  }
}

void main() {
  group('GetBarcodeProductInfo', () {
    test('passes user data to BarcodeApiService when available', () async {
      final api = FakeBarcodeApiService();
      final users = FakeUserRepository();
      final usecase = GetBarcodeProductInfo(api, users);

      const barcode = '1234567890123';
      users.user = const UserDataEntity(
        age: 20,
        height: 170,
        weight: 60,
        goalWeightKg: 55,
        disease: 'none',
        allergy: 'none',
        goal: 'cut',
        gender: 'male',
      );

      final product = BarcodeProduct(barcode: barcode, productName: 'Test');

      api.response = product;

      final result = await usecase(barcode);

      expect(result, same(product));

      expect(api.lastBarcode, barcode);
      expect(api.lastUserData, isNotNull);
      expect(api.lastUserData!['age'], 20);
      expect(api.lastUserData!['height'], 170);
      expect(api.lastUserData!['weight'], 60);
      expect(api.lastUserData!['goalWeightKg'], 55);
      expect(api.lastUserData!['disease'], 'none');
      expect(api.lastUserData!['allergy'], 'none');
      expect(api.lastUserData!['goal'], 'cut');
      expect(api.lastUserData!['gender'], 'male');
    });

    test('still calls API when user lookup fails', () async {
      final api = FakeBarcodeApiService();
      final users = FakeUserRepository();
      final usecase = GetBarcodeProductInfo(api, users);

      const barcode = '999';
      final product = BarcodeProduct(barcode: barcode, productName: 'P');

      users.throwOnGet = Exception('boom');
      api.response = product;

      final result = await usecase(barcode);

      expect(result, same(product));
      expect(api.lastBarcode, barcode);
    });
  });
}
