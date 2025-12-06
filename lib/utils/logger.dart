import 'package:flutter/foundation.dart';

/// Simple logging utility for production-safe logging
class AppLogger {
  static const String _tag = 'AppLogger';

  /// Log debug messages (only in debug mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('[$logTag] 🔍 $message');
    }
  }

  /// Log info messages
  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('[$logTag] ℹ️ $message');
    }
  }

  /// Log warning messages
  static void warning(String message, {String? tag}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('[$logTag] ⚠️ $message');
    }
  }

  /// Log error messages
  static void error(String message, {String? tag, dynamic error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final logTag = tag ?? _tag;
      debugPrint('[$logTag] ❌ $message');
      if (error != null) {
        debugPrint('[$logTag] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[$logTag] StackTrace: $stackTrace');
      }
    }
  }
}

