import 'package:flutter/material.dart';
import '../../../../common/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../responsive/responsive.dart';
import '../../domain/entities/notification_item.dart';
import 'package:intl/intl.dart';

/// Trang hiển thị danh sách thông báo
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final now = DateTime.now();
    
    // Notification mặc định về uống nước
    _notifications = [
      NotificationItem(
        id: 'water_reminder_default',
        title: '', // Sẽ set trong build với localization
        message: '', // Sẽ set trong build với localization
        icon: Icons.water_drop_outlined,
        timestamp: now,
        isRead: false,
        type: NotificationType.reminder,
      ),
    ];
  }

  void _markAsRead(String id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final responsive = ResponsiveHelper.of(context);
    final theme = Theme.of(context);

    // Update default notification với localization
    if (_notifications.isNotEmpty && _notifications[0].id == 'water_reminder_default') {
      _notifications[0] = NotificationItem(
        id: 'water_reminder_default',
        title: localizations?.waterReminderTitle ?? 'Nhắc nhở uống nước',
        message: localizations?.waterReminderMessage ?? 'Uống đủ nước mỗi ngày giúp cơ thể khỏe mạnh!',
        icon: Icons.water_drop_outlined,
        timestamp: _notifications[0].timestamp,
        isRead: _notifications[0].isRead,
        type: NotificationType.reminder,
      );
    }

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: CustomAppBar(
        title: localizations?.notificationTitle ?? 'Thông báo',
        showBackButton: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                localizations?.markAllAsRead ?? 'Đọc tất cả',
                style: TextStyle(
                  fontSize: responsive.fontSize(14),
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(context, responsive, theme)
          : ListView.separated(
              padding: EdgeInsets.all(responsive.width(16)),
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => SizedBox(
                height: responsive.height(12),
              ),
              itemBuilder: (context, index) {
                return _buildNotificationItem(
                  context,
                  _notifications[index],
                  responsive,
                  theme,
                  localizations,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ResponsiveHelper responsive,
    ThemeData theme,
  ) {
    final localizations = AppLocalizations.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: responsive.iconSize(64),
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: responsive.height(16)),
          Text(
            localizations?.noNotifications ?? 'Chưa có thông báo nào',
            style: TextStyle(
              fontSize: responsive.fontSize(16),
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    NotificationItem notification,
    ResponsiveHelper responsive,
    ThemeData theme,
    AppLocalizations? localizations,
  ) {
    final locale = localizations?.localeName ?? 'vi';
    final timeFormat = DateFormat('HH:mm', locale);
    final dateFormat = DateFormat('dd/MM/yyyy', locale);
    
    final now = DateTime.now();
    final isToday = notification.timestamp.year == now.year &&
        notification.timestamp.month == now.month &&
        notification.timestamp.day == now.day;

    final timeText = isToday
        ? timeFormat.format(notification.timestamp)
        : dateFormat.format(notification.timestamp);

    Color iconColor;
    Color backgroundColor;
    
    switch (notification.type) {
      case NotificationType.reminder:
        iconColor = Colors.blue;
        backgroundColor = Colors.blue.withOpacity(0.1);
        break;
      case NotificationType.achievement:
        iconColor = Colors.amber;
        backgroundColor = Colors.amber.withOpacity(0.1);
        break;
      case NotificationType.warning:
        iconColor = Colors.orange;
        backgroundColor = Colors.orange.withOpacity(0.1);
        break;
      default:
        iconColor = theme.colorScheme.primary;
        backgroundColor = theme.colorScheme.primaryContainer.withOpacity(0.3);
    }

    return InkWell(
      onTap: () => _markAsRead(notification.id),
      borderRadius: BorderRadius.circular(responsive.radius(12)),
      child: Container(
        padding: EdgeInsets.all(responsive.width(16)),
        decoration: BoxDecoration(
          color: notification.isRead
              ? theme.colorScheme.surface
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          border: Border.all(
            color: notification.isRead
                ? theme.colorScheme.outline.withOpacity(0.2)
                : theme.colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(responsive.width(10)),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(responsive.radius(10)),
              ),
              child: Icon(
                notification.icon,
                size: responsive.iconSize(24),
                color: iconColor,
              ),
            ),
            SizedBox(width: responsive.width(12)),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: responsive.fontSize(15),
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: responsive.width(8),
                          height: responsive.width(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: responsive.height(4)),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: responsive.fontSize(13),
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: responsive.height(8)),
                  Text(
                    timeText,
                    style: TextStyle(
                      fontSize: responsive.fontSize(12),
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
