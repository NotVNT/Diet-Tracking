import 'package:permission_handler/permission_handler.dart' as ph;
import '../../../../services/permission_service.dart';

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
  final PermissionService _permissionService;

  RequestCameraPermission(this._permissionService);

  /// Yêu cầu quyền camera
  ///
  /// Trả về [CameraPermissionResult] chứa:
  /// - [hasPermission]: true nếu có quyền
  /// - [errorMessage]: thông báo lỗi (nếu có)
  /// - [isPermanentlyDenied]: true nếu quyền bị từ chối vĩnh viễn
  Future<CameraPermissionResult> call() async {
    final status = await _permissionService.getCameraPermissionStatus();

    // Nếu đã có quyền
    if (status == ph.PermissionStatus.granted ||
        status == ph.PermissionStatus.limited) {
      return CameraPermissionResult(
        hasPermission: true,
        isPermanentlyDenied: false,
      );
    }

    // Nếu quyền bị từ chối vĩnh viễn
    if (status == ph.PermissionStatus.permanentlyDenied) {
      return CameraPermissionResult(
        hasPermission: false,
        errorMessage: 'Hãy bật quyền camera trong Cài đặt để tiếp tục quét.',
        isPermanentlyDenied: true,
      );
    }

    // Nếu quyền bị từ chối hoặc bị hạn chế, yêu cầu quyền
    if (status == ph.PermissionStatus.denied ||
        status == ph.PermissionStatus.restricted) {
      final requested =
          await _permissionService.requestCameraPermissionStatus(useSessionCache: true);
      if (requested == ph.PermissionStatus.granted ||
          requested == ph.PermissionStatus.limited) {
        return CameraPermissionResult(
          hasPermission: true,
          isPermanentlyDenied: false,
        );
      }

      if (requested == ph.PermissionStatus.permanentlyDenied) {
        return CameraPermissionResult(
          hasPermission: false,
          errorMessage: 'Hãy bật quyền camera trong Cài đặt để tiếp tục quét.',
          isPermanentlyDenied: true,
        );
      }

      return CameraPermissionResult(
        hasPermission: false,
        errorMessage: 'Ứng dụng cần quyền camera để quét.',
        isPermanentlyDenied: false,
      );
    }

    return CameraPermissionResult(
      hasPermission: false,
      errorMessage: 'Không thể xác định trạng thái quyền camera.',
      isPermanentlyDenied: false,
    );
  }
}