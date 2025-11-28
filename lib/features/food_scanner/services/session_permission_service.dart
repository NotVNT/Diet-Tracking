import 'package:permission_handler/permission_handler.dart' as ph;

/// Tracks camera permission state within a single login session
/// 
/// Behavior:
/// - If user selects 'While using the app' or 'Only this time' → permission dialog never appears again in this session
/// - If user selects 'Don't allow' → permission dialog appears every time they tap Scan Food
/// - When user logs out, the session state is reset
class SessionPermissionService {
  static final SessionPermissionService _instance = SessionPermissionService._internal();

  factory SessionPermissionService() {
    return _instance;
  }

  SessionPermissionService._internal();

  // Track if permission has been granted/limited in this session
  bool _cameraPermissionGrantedInSession = false;

  // Track if user has explicitly denied permission in this session
  bool _cameraPermissionDeniedInSession = false;

  /// Request camera permission with session-aware behavior
  /// 
  /// Returns true if permission is granted or limited
  /// Returns false if permission is denied
  /// 
  /// If user previously granted/limited permission in this session, 
  /// the dialog won't appear again (returns true)
  /// 
  /// If user previously denied permission in this session,
  /// the dialog will appear again
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

