import 'local_storage_service.dart';
import 'auth_service.dart';
import '../model/body_info_model.dart';

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

    // Tạo BodyInfoModel từ dữ liệu guest
    final bodyInfo = BodyInfoModel(
      heightCm: data['heightCm'] as double?,
      weightKg: data['weightKg'] as double?,
      health: _parseHealth(data['health'] as String?),
    );

    // Chỉ thêm bodyInfo nếu có ít nhất một thuộc tính không null
    if (bodyInfo.heightCm != null ||
        bodyInfo.weightKg != null ||
        bodyInfo.health != null) {
      update['bodyInfo'] = bodyInfo.toJson();
    }

    if (data['age'] != null) {
      update['age'] = data['age'];
    }
    if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
      update['gender'] = data['gender'];
    }

    // Đồng bộ bệnh lý và dị ứng nếu có
    final List<String>? medical = (data['medicalConditions'] as List?)
        ?.map((e) => e.toString())
        .toList();
    final List<String>? allergies = (data['allergies'] as List?)
        ?.map((e) => e.toString())
        .toList();
    if (medical != null && medical.isNotEmpty) {
      update['bodyInfo'] = {
        ...(update['bodyInfo'] as Map<String, dynamic>? ?? bodyInfo.toJson()),
        'medicalConditions': medical,
      };
    }
    if (allergies != null && allergies.isNotEmpty) {
      update['bodyInfo'] = {
        ...(update['bodyInfo'] as Map<String, dynamic>? ?? bodyInfo.toJson()),
        'allergies': allergies,
      };
    }

    // goalWeightKg
    final double? goalWeightKg = data['goalWeightKg'] as double?;
    if (goalWeightKg != null) {
      update['bodyInfo'] = {
        ...(update['bodyInfo'] as Map<String, dynamic>? ?? bodyInfo.toJson()),
        'goalWeightKg': goalWeightKg,
      };
    }

    if (update.isEmpty) {
      await _local.clearGuestData();
      return;
    }

    await _auth.updateUserData(uid, update);
    await _local.clearGuestData();
  }

  /// Parse health status from string
  HealthStatus? _parseHealth(String? health) {
    if (health == null) return null;
    try {
      return HealthStatus.values.firstWhere((e) => e.name == health);
    } catch (_) {
      return HealthStatus.unknown;
    }
  }
}
