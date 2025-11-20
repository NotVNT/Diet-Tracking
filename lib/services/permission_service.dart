import 'package:permission_handler/permission_handler.dart' as ph;

/// Service to handle app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  /// Request camera permission with a single prompt
  /// Returns true if permission is granted or limited
  /// Returns false if permission is denied or permanently denied
  Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted || status.isLimited;
  }

  /// Check if camera permission is already granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await ph.Permission.camera.status;
    return status.isGranted || status.isLimited;
  }

  /// Open app settings to allow user to manually grant permission
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}

