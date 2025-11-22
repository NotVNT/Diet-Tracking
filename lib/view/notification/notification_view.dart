import 'package:flutter/material.dart';
import '../../model/notification_model.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  // Dummy data for demonstration
  final List<NotificationModel> _notifications = [
    
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
              radius: 5,
            ),
            title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(notification.body),
            trailing: Text('${DateTime.now().difference(notification.timestamp).inMinutes}m ago'),
            onTap: () {
              setState(() {
                // Mark as read when tapped
                // In a real app, you would update the model like this:
                // _notifications[index] = notification.copyWith(isRead: true);
              });
            },
          );
        },
      ),
    );
  }
}

