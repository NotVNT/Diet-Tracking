import 'package:permission_handler/permission_handler.dart' as ph;

class CameraPermissionService {
  static final CameraPermissionService _instance = CameraPermissionService._internal();

  factory CameraPermissionService() {
    return _instance;
  }

  CameraPermissionService._internal();

  // Track if permission has been granted/limited in this session
  bool _cameraPermissionGrantedInSession = false;

  // Track if user has explicitly denied permission in this session
  bool _cameraPermissionDeniedInSession = false;

  Future<bool> requestCameraPermission() async {
    // If already granted in this session, don't show dialog again
    if (_cameraPermissionGrantedInSession) {
      return true;
    }

    // Request permission from OS
    final status = await ph.Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      // Mark as granted in this session
      _cameraPermissionGrantedInSession = true;
      _cameraPermissionDeniedInSession = false;
      return true;
    }

    if (status.isDenied) {
      // Mark as denied in this session (dialog will appear next time)
      _cameraPermissionDeniedInSession = true;
      return false;
    }

    if (status.isPermanentlyDenied) {
      // Permanently denied - don't show dialog again
      _cameraPermissionGrantedInSession = true;
      return false;
    }

    return false;
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

  /// Reset session state when user logs out
  /// Call this when the user logs out to clear session permission state
  void resetSessionState() {
    _cameraPermissionGrantedInSession = false;
    _cameraPermissionDeniedInSession = false;
  }

  /// Get current session state (for debugging)
  Map<String, bool> getSessionState() {
    return {
      'cameraPermissionGrantedInSession': _cameraPermissionGrantedInSession,
      'cameraPermissionDeniedInSession': _cameraPermissionDeniedInSession,
    };
  }
}

