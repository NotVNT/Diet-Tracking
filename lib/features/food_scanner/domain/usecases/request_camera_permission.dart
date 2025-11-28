import 'package:permission_handler/permission_handler.dart';
import '../../services/camera_permission_service.dart';

/// Model chứa kết quả của việc yêu cầu quyền camera
class CameraPermissionResult {
  final bool hasPermission;
  final String? errorMessage;
  final bool isPermanentlyDenied;

  CameraPermissionResult({
    required this.hasPermission,
    this.errorMessage,
    required this.isPermanentlyDenied,
  });
}

/// Use case để yêu cầu quyền camera
///
/// Chịu trách nhiệm cho việc:
/// - Kiểm tra trạng thái quyền camera hiện tại
/// - Yêu cầu quyền camera từ hệ thống
/// - Trả về kết quả và thông báo lỗi nếu cần
class RequestCameraPermission {
  final CameraPermissionService _sessionPermissionService;

  RequestCameraPermission(this._sessionPermissionService);

  /// Yêu cầu quyền camera
  ///
  /// Trả về [CameraPermissionResult] chứa:
  /// - [hasPermission]: true nếu có quyền
  /// - [errorMessage]: thông báo lỗi (nếu có)
  /// - [isPermanentlyDenied]: true nếu quyền bị từ chối vĩnh viễn
  Future<CameraPermissionResult> call() async {
    var status = await Permission.camera.status;

    // Nếu đã có quyền
    if (status.isGranted || status.isLimited) {
      return CameraPermissionResult(
        hasPermission: true,
        isPermanentlyDenied: false,
      );
    }

    // Nếu quyền bị từ chối vĩnh viễn
    if (status.isPermanentlyDenied) {
      return CameraPermissionResult(
        hasPermission: false,
        errorMessage: 'Hãy bật quyền camera trong Cài đặt để tiếp tục quét.',
        isPermanentlyDenied: true,
      );
    }

    // Nếu quyền bị từ chối hoặc bị hạn chế, yêu cầu quyền
    if (status.isDenied || status.isRestricted) {
      final hasPermission = await _sessionPermissionService.requestCameraPermission();
      if (hasPermission) {
        return CameraPermissionResult(
          hasPermission: true,
          isPermanentlyDenied: false,
        );
      } else {
        return CameraPermissionResult(
          hasPermission: false,
          errorMessage: 'Ứng dụng cần quyền camera để quét.',
          isPermanentlyDenied: false,
        );
      }
    }

    return CameraPermissionResult(
      hasPermission: false,
      errorMessage: 'Không thể xác định trạng thái quyền camera.',
      isPermanentlyDenied: false,
    );
  }
}