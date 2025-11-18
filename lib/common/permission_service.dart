import 'package:flutter/material.dart';
import 'permission_dialog.dart';

/// Service quản lý quyền truy cập camera
/// 
/// Class này cung cấp các phương thức để:
/// - Hiển thị dialog yêu cầu quyền
/// - Xử lý các lựa chọn của người dùng
class PermissionService {
  /// Hiển thị dialog yêu cầu quyền camera
  /// 
  /// Tham số:
  /// - context: BuildContext để hiển thị dialog
  /// - onPermissionGranted: Callback khi người dùng cấp quyền
  static Future<void> requestCameraPermission(
    BuildContext context, {
    required VoidCallback onPermissionGranted,
  }) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext dialogContext) {
        return PermissionDialog(
          title: 'Cho phép Diet Tracking chụp ảnh và quay video?',
          message: '',
          onAllow: () {
            Navigator.of(dialogContext).pop();
            onPermissionGranted();
          },
          onAllowOnce: () {
            Navigator.of(dialogContext).pop();
            onPermissionGranted();
          },
          onDeny: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }
}
