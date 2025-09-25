import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService', () {
    late LocalStorageService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = LocalStorageService();
    });

    test('saveGuestData và readGuestData hoạt động đúng', () async {
      await service.saveGuestData(
        goal: 'lose_weight, gain_muscle',
        heightCm: 175.5,
        weightKg: 70.2,
        age: 28,
        gender: 'male',
      );

      final data = await service.readGuestData();
      expect(data['goal'], 'lose_weight, gain_muscle');
      expect(data['heightCm'], 175.5);
      expect(data['weightKg'], 70.2);
      expect(data['age'], 28);
      expect(data['gender'], 'male');
    });

    test('hasGuestData trả về true khi có bất kỳ trường nào', () async {
      expect(await service.hasGuestData(), false);
      await service.saveGuestData(goal: 'a');
      expect(await service.hasGuestData(), true);
    });

    test('clearGuestData xóa toàn bộ dữ liệu', () async {
      await service.saveGuestData(
        goal: 'x',
        heightCm: 160,
        weightKg: 50,
        age: 20,
        gender: 'female',
      );

      await service.clearGuestData();

      final data = await service.readGuestData();
      expect(data['goal'], isNull);
      expect(data['heightCm'], isNull);
      expect(data['weightKg'], isNull);
      expect(data['age'], isNull);
      expect(data['gender'], isNull);
      expect(await service.hasGuestData(), false);
    });
  });
}

