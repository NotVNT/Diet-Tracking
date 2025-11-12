import 'package:flutter/material.dart';

/// Model cho notification item
class NotificationItem {
  final String id;
  final String title;
  final String message;
  final IconData icon;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.icon,
    required this.timestamp,
    this.isRead = false,
    this.type = NotificationType.info,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    IconData? icon,
    DateTime? timestamp,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

/// Loại notification
enum NotificationType {
  info,
  reminder,
  achievement,
  warning,
}
