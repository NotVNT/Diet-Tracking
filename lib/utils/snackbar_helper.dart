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
        margin: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 70.0),
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
      backgroundColor: Theme.of(context).colorScheme.primary,
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
      backgroundColor: Theme.of(context).colorScheme.error,
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
      backgroundColor: Theme.of(context).colorScheme.secondary,
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
      backgroundColor: Theme.of(context).colorScheme.tertiary,
    );
  }
}
