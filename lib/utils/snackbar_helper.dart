import 'package:flutter/material.dart';

/// Helper class for showing SnackBars with consistent positioning
/// SnackBars will appear above the bottom navigation bar and floating action button
class SnackBarHelper {
  /// Show a SnackBar with default styling and positioning above bottom navigation
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.12, // Above bottom nav
          left: 16,
          right: 16,
        ),
      ),
    );
  }

  /// Show a success SnackBar with green background
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.green.shade600,
    );
  }

  /// Show an error SnackBar with red background
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.red.shade600,
    );
  }

  /// Show an info SnackBar with blue background
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.blue.shade600,
    );
  }

  /// Show a warning SnackBar with orange background
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      context,
      message,
      duration: duration,
      backgroundColor: Colors.orange.shade600,
    );
  }
}
