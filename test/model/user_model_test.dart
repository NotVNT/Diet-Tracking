import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/model/user.dart';
import 'package:diet_tracking_project/model/body_info_model.dart';

void main() {
  group('User model', () {
    test('toJson và fromJson giữ nguyên dữ liệu (các trường đang hỗ trợ)', () {
      final user = User(
        uid: 'u1',
        email: 'a@a.com',
        fullName: 'A',
        phone: '0123',
        gender: GenderType.male,
        age: 24,
        bodyInfo: const BodyInfoModel(heightCm: 170.5, weightKg: 65.2),
      );
      final json = user.toJson();
      final parsed = User.fromJson(json);

      expect(parsed.uid, 'u1');
      expect(parsed.email, 'a@a.com');
      expect(parsed.fullName, 'A');
      expect(parsed.phone, '0123');
      expect(parsed.gender, GenderType.male);
      expect(parsed.age, 24);
      expect(parsed.bodyInfo?.heightCm, 170.5);
      expect(parsed.bodyInfo?.weightKg, 65.2);
    });

    test('fromJson null-safe và parse gender/bodyInfo hợp lệ', () {
      final parsed = User.fromJson({
        'uid': 'u2',
        'gender': 'female',
        'bodyInfo': {'heightCm': 160, 'weightKg': 50},
      });
      expect(parsed.uid, 'u2');
      expect(parsed.gender, GenderType.female);
      expect(parsed.bodyInfo?.heightCm, 160.0);
      expect(parsed.bodyInfo?.weightKg, 50.0);
    });

    test('copyWith cập nhật trường chọn lọc', () {
      final user = User(uid: 'u1', fullName: 'A');
      final updated = user.copyWith(
        fullName: 'B',
        bodyInfo: const BodyInfoModel(heightCm: 180),
      );
      expect(updated.uid, 'u1');
      expect(updated.fullName, 'B');
      expect(updated.bodyInfo?.heightCm, 180);
    });
  });
}
