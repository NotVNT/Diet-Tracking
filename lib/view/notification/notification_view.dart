import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

import 'notification_provider.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.inboxTitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          final notifications = provider.notifications;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey
                      : Theme.of(context).primaryColor,
                  radius: 5,
                ),
                title: Text(notification.title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(notification.body),
                trailing: Text(
                    '${DateTime.now().difference(notification.timestamp).inMinutes}m ago'),
                onTap: () {
                  provider.markAsRead(notification.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}

