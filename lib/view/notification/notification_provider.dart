import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../model/notification_model.dart';

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => _notifications;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void addNotification({required String title, required String body}) {
    final newNotification = NotificationModel(
      id: const Uuid().v4(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, newNotification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      notifyListeners();
    }
  }
}
