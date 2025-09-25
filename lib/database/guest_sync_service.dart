import 'local_storage_service.dart';
import 'auth_service.dart';

class GuestSyncService {
  final LocalStorageService _local = LocalStorageService();
  final AuthService _auth = AuthService();

  Future<void> syncGuestToUser(String uid) async {
    final hasData = await _local.hasGuestData();
    if (!hasData) return;

    final data = await _local.readGuestData();
    final Map<String, dynamic> update = {};

    if (data['goal'] != null && (data['goal'] as String).isNotEmpty) {
      // goal lưu tạm dạng chuỗi, chuyển thành List<String> khi đẩy lên Firestore
      final parts = (data['goal'] as String)
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      update['goal'] = parts.isEmpty ? null : parts;
    }
    if (data['heightCm'] != null) {
      update['heightCm'] = data['heightCm'];
    }
    if (data['weightKg'] != null) {
      update['weightKg'] = data['weightKg'];
    }
    if (data['age'] != null) {
      update['age'] = data['age'];
    }
    if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
      update['gender'] = data['gender'];
    }

    if (update.isEmpty) {
      await _local.clearGuestData();
      return;
    }

    await _auth.updateUserData(uid, update);
    await _local.clearGuestData();
  }
}
