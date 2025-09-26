import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('saveGuestData và readGuestData hoạt động đúng', () async {
      final svc = LocalStorageService();
      await svc.saveGuestData(
        goal: 'loseWeight',
        heightCm: 172.5,
        weightKg: 68.2,
        age: 26,
        gender: 'male',
      );

      final data = await svc.readGuestData();
      expect(data['goal'], 'loseWeight');
      expect(data['heightCm'], 172.5);
      expect(data['weightKg'], 68.2);
      expect(data['age'], 26);
      expect(data['gender'], 'male');
    });

    test('hasGuestData trả về true khi có ít nhất một trường', () async {
      final svc = LocalStorageService();
      expect(await svc.hasGuestData(), false);
      await svc.saveGuestData(goal: 'maintain');
      expect(await svc.hasGuestData(), true);
    });

    test('clearGuestData xóa hết dữ liệu', () async {
      final svc = LocalStorageService();
      await svc.saveGuestData(goal: 'a', age: 20, gender: 'female');
      expect(await svc.hasGuestData(), true);
      await svc.clearGuestData();
      expect(await svc.hasGuestData(), false);
      final data = await svc.readGuestData();
      expect(data['goal'], isNull);
      expect(data['age'], isNull);
      expect(data['gender'], isNull);
    });
  });
}
