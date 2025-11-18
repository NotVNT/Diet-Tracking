import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'permission_dialog_foodScanner.dart';

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
    final currentStatus = await Permission.camera.status;
    if (_isGranted(currentStatus)) {
      onPermissionGranted();
      return;
    }

    if (currentStatus == PermissionStatus.permanentlyDenied) {
      await _showSettingsDialog(context);
      return;
    }

    final shouldExplain = await Permission.camera.shouldShowRequestRationale;
    if (shouldExplain) {
      await _showEducationDialog(context, onPermissionGranted);
      return;
    }

    await _handlePermissionRequest(context, onPermissionGranted);
  }

  static bool _isGranted(PermissionStatus status) =>
      status == PermissionStatus.granted || status == PermissionStatus.limited;

  static Future<void> _showEducationDialog(
    BuildContext context,
    VoidCallback onPermissionGranted,
  ) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return PermissionDialog(
          title: 'Cho phép Diet Tracking chụp ảnh và quay video?',
          message:
              'Ứng dụng cần quyền camera để quét thực phẩm. Vui lòng xác nhận để tiếp tục.',
          onAllow: () async {
            Navigator.of(dialogContext).pop();
            await _handlePermissionRequest(context, onPermissionGranted);
          },
          onAllowOnce: () async {
            Navigator.of(dialogContext).pop();
            await _handlePermissionRequest(context, onPermissionGranted);
          },
          onDeny: () async {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  static Future<void> _showSettingsDialog(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return PermissionDialog(
          title: 'Diet Tracking cần quyền camera',
          message:
              'Bạn đã tắt quyền camera. Mở cài đặt để cấp quyền và tiếp tục sử dụng tính năng quét.',
          allowLabel: 'MỞ CÀI ĐẶT',
          allowOnceLabel: 'THỬ LẠI',
          denyLabel: 'ĐÓNG',
          onAllow: () async {
            Navigator.of(dialogContext).pop();
            await openAppSettings();
          },
          onAllowOnce: () async {
            Navigator.of(dialogContext).pop();
            await Permission.camera.request();
          },
          onDeny: () async {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
  }

  static Future<void> _handlePermissionRequest(
    BuildContext context,
    VoidCallback onPermissionGranted,
  ) async {
    final status = await Permission.camera.request();
    if (_isGranted(status)) {
      onPermissionGranted();
      return;
    }

    if (status == PermissionStatus.permanentlyDenied) {
      await _showSettingsDialog(context);
      return;
    }

    // Người dùng đã từ chối, không hiển thị SnackBar theo yêu cầu.
  }
}
