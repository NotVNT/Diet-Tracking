import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/model/user.dart';

void main() {
  group('User model', () {
    test('toJson và fromJson giữ nguyên dữ liệu', () {
      final user = User(
        uid: 'u1',
        email: 'a@a.com',
        fullName: 'A',
        phone: '0123',
        birthDate: DateTime(2000, 1, 2),
        gender: GenderType.male,
        age: 24,
        heightCm: 170.5,
        weightKg: 65.2,
        activityLevel: ActivityLevel.moderate,
        goals: ['loseWeight', 'gainMuscle'],
        avatarUrl: 'http://x/y.png',
      );
      final json = user.toJson();
      final parsed = User.fromJson(json);

      expect(parsed.uid, 'u1');
      expect(parsed.email, 'a@a.com');
      expect(parsed.fullName, 'A');
      expect(parsed.phone, '0123');
      expect(parsed.birthDate, user.birthDate);
      expect(parsed.gender, GenderType.male);
      expect(parsed.age, 24);
      expect(parsed.heightCm, 170.5);
      expect(parsed.weightKg, 65.2);
      expect(parsed.activityLevel, ActivityLevel.moderate);
      expect(parsed.goals, ['loseWeight', 'gainMuscle']);
      expect(parsed.avatarUrl, 'http://x/y.png');
    });

    test('fromJson parse chuỗi goals và null-safe', () {
      final parsed = User.fromJson({
        'uid': 'u2',
        'goal': 'a, b , c',
        'gender': 'female',
        'activityLevel': 'active',
        'heightCm': 160,
        'weightKg': 50,
      });
      expect(parsed.uid, 'u2');
      expect(parsed.goals, ['a', 'b', 'c']);
      expect(parsed.gender, GenderType.female);
      expect(parsed.activityLevel, ActivityLevel.active);
      expect(parsed.heightCm, 160.0);
      expect(parsed.weightKg, 50.0);
    });

    test('copyWith cập nhật trường chọn lọc', () {
      final user = User(uid: 'u1', fullName: 'A');
      final updated = user.copyWith(fullName: 'B', heightCm: 180);
      expect(updated.uid, 'u1');
      expect(updated.fullName, 'B');
      expect(updated.heightCm, 180);
    });
  });
}

