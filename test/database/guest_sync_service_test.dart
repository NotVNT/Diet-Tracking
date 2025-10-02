import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:diet_tracking_project/database/local_storage_service.dart';
import 'package:diet_tracking_project/database/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

// Tạo fake GuestSyncService sử dụng dependency injection đơn giản thông qua extends
class _GuestSyncServiceForTest {
  final LocalStorageService local;
  final AuthService auth;
  _GuestSyncServiceForTest(this.local, this.auth);

  Future<void> syncGuestToUser(String uid) async {
    final hasData = await local.hasGuestData();
    if (!hasData) return;
    final data = await local.readGuestData();
    final Map<String, dynamic> update = {};

    // Phù hợp với GuestSyncService hiện tại: gói height/weight vào bodyInfo
    final Map<String, dynamic> bodyInfo = {};
    if (data['heightCm'] != null) bodyInfo['heightCm'] = data['heightCm'];
    if (data['weightKg'] != null) bodyInfo['weightKg'] = data['weightKg'];
    if (bodyInfo.isNotEmpty) {
      update['bodyInfo'] = bodyInfo;
    }
    if (data['age'] != null) update['age'] = data['age'];
    if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
      update['gender'] = data['gender'];
    }

    if (update.isEmpty) {
      await local.clearGuestData();
      return;
    }
    await auth.updateUserData(uid, update);
    await local.clearGuestData();
  }
}

class _RecordingAuthService extends AuthService {
  String? lastUid;
  Map<String, dynamic>? lastData;
  _RecordingAuthService()
    : super(auth: _DummyAuth(), firestore: FakeFirebaseFirestore());

  @override
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    lastUid = uid;
    lastData = data;
  }
}

class _DummyAuth extends Mock implements FirebaseAuth {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GuestSyncService', () {
    late LocalStorageService local;
    late _RecordingAuthService auth;
    late _GuestSyncServiceForTest svc;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      local = LocalStorageService();
      auth = _RecordingAuthService();
      svc = _GuestSyncServiceForTest(local, auth);
    });

    test('Không làm gì nếu không có dữ liệu', () async {
      await svc.syncGuestToUser('uid');
      expect(auth.lastUid, isNull);
      expect(await local.hasGuestData(), false);
    });

    test('Đẩy dữ liệu hợp lệ và xóa local', () async {
      await local.saveGuestData(
        goal: 'lose, gain',
        heightCm: 170,
        weightKg: 65,
        age: 25,
        gender: 'male',
      );

      await svc.syncGuestToUser('uid-1');

      expect(auth.lastUid, 'uid-1');
      expect(auth.lastData, {
        'bodyInfo': {'heightCm': 170.0, 'weightKg': 65.0},
        'age': 25,
        'gender': 'male',
      });

      expect(await local.hasGuestData(), false);
    });

    test('Dữ liệu rỗng dẫn tới chỉ clear, không update', () async {
      await local.saveGuestData(goal: '');
      await svc.syncGuestToUser('uid-2');
      expect(auth.lastUid, isNull);
      expect(await local.hasGuestData(), false);
    });
  });
}
