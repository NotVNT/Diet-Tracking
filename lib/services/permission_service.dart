import 'package:permission_handler/permission_handler.dart' as ph;

/// Service to handle app permissions
class PermissionService {
  static final PermissionService _instance = PermissionService._internal();

  factory PermissionService() {
    return _instance;
  }

  PermissionService._internal();

  // Track if camera permission has been granted/limited in this session.
  // Used to avoid repeatedly showing the permission dialog in flows like scanners.
  bool _cameraPermissionGrantedInSession = false;

  // Track if user has explicitly denied camera permission in this session.
  bool _cameraPermissionDeniedInSession = false;

  /// Get current OS camera permission status.
  ///
  /// Exposed as a method to make permission flows testable (can be mocked).
  Future<ph.PermissionStatus> getCameraPermissionStatus() async {
    return ph.Permission.camera.status;
  }

  /// Request camera permission with a single prompt
  /// Returns true if permission is granted or limited
  /// Returns false if permission is denied or permanently denied
  Future<bool> requestCameraPermission() async {
    final status = await requestCameraPermissionStatus();
    return status.isGranted || status.isLimited;
  }

  /// Request OS camera permission and return the resulting status.
  ///
  /// Use this when the caller needs to handle denied/permanentlyDenied flows.
  ///
  /// If [useSessionCache] is true, the service will avoid re-prompting within the
  /// current app session once permission has been granted/limited (or permanently
  /// denied).
  Future<ph.PermissionStatus> requestCameraPermissionStatus({
    bool useSessionCache = false,
  }) async {
    if (!useSessionCache) {
      return ph.Permission.camera.request();
    }

    // If already granted in this session, don't show dialog again.
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
      // Permanently denied - don't show dialog again in this session.
      _cameraPermissionGrantedInSession = true;
      return status;
    }

    return status;
  }

  /// Check if camera permission is already granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await getCameraPermissionStatus();
    return status.isGranted || status.isLimited;
  }

  /// Reset session state when user logs out.
  ///
  /// This only affects the in-memory session cache, not the OS permission status.
  void resetSessionState() {
    _cameraPermissionGrantedInSession = false;
    _cameraPermissionDeniedInSession = false;
  }

  /// Get current session state (for debugging).
  Map<String, bool> getSessionState() {
    return {
      'cameraPermissionGrantedInSession': _cameraPermissionGrantedInSession,
      'cameraPermissionDeniedInSession': _cameraPermissionDeniedInSession,
    };
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

  /// Request microphone permission
  Future<bool> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted || status.isLimited;
  }

  /// Request OS microphone permission and return the resulting status.
  ///
  /// Use this when the caller needs to handle denied/permanentlyDenied flows.
  Future<ph.PermissionStatus> requestMicrophonePermissionStatus() async {
    return ph.Permission.microphone.request();
  }

  /// Open app settings to allow user to manually grant permission
  Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}

