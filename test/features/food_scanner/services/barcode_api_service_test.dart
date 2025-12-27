import 'package:flutter_test/flutter_test.dart';

import 'package:diet_tracking_project/features/food_scanner/services/barcode_api_service.dart';

void main() {
  group('BarcodeApiService URL resolution', () {
    test('can be constructed', () {
      // We can't assert environment-dependent values in tests reliably
      // (String.fromEnvironment is compile-time), but we can at least ensure
      // the class is instantiable.
      final svc = BarcodeApiService();
      expect(svc, isNotNull);
    });
  });
}
