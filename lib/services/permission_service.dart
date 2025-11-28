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

  /// Request notification permission (Android 13+ and iOS)
  /// Returns true if permission is granted or limited
  /// Returns false if permission is denied or permanently denied
  Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted || status.isLimited;
  }

  /// Check notification permission status
  Future<bool> isNotificationPermissionGranted() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  /// Open app settings to allow user to manually grant permission
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}

