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

  /// Get current OS camera permission status.
  ///
  /// Exposed as a method to make permission flows testable (can be mocked).
  Future<ph.PermissionStatus> getCameraPermissionStatus() async {
    return ph.Permission.camera.status;
  }

  /// Request OS camera permission and return the resulting status.
  ///
  /// Exposed as a method to make permission flows testable (can be mocked).
  Future<ph.PermissionStatus> requestCameraPermissionStatus() async {
    // If already granted in this session, don't show dialog again
    if (_cameraPermissionGrantedInSession) {
      return ph.PermissionStatus.granted;
    }

    final status = await ph.Permission.camera.request();

    if (status.isGranted || status.isLimited) {
      _cameraPermissionGrantedInSession = true;
      _cameraPermissionDeniedInSession = false;
      return status;
    }

    if (status.isDenied) {
      _cameraPermissionDeniedInSession = true;
      return status;
    }

    if (status.isPermanentlyDenied) {
      // Permanently denied - don't show dialog again in this session
      _cameraPermissionGrantedInSession = true;
      return status;
    }

    return status;
  }

  Future<bool> requestCameraPermission() async {
    final status = await requestCameraPermissionStatus();
    return status.isGranted || status.isLimited;
  }

  /// Check if camera permission is already granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await getCameraPermissionStatus();
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

