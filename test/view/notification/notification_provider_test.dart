import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';

void main() {
  group('NotificationProvider', () {
    test('addNotification thêm thông báo mới, đứng đầu danh sách và tăng unreadCount', () {
      final provider = NotificationProvider();

      expect(provider.notifications, isEmpty);
      expect(provider.unreadCount, 0);

      provider.addNotification(title: 'Title 1', body: 'Body 1');
      provider.addNotification(title: 'Title 2', body: 'Body 2');

      expect(provider.notifications.length, 2);
      // Phần tử mới nhất đứng đầu danh sách
      expect(provider.notifications.first.title, 'Title 2');
      expect(provider.unreadCount, 2);
    });

    test('markAsRead đánh dấu đã đọc và giảm unreadCount', () {
      final provider = NotificationProvider();
      provider.addNotification(title: 'Title 1', body: 'Body 1');
      provider.addNotification(title: 'Title 2', body: 'Body 2');

      final idToRead = provider.notifications.first.id;
      provider.markAsRead(idToRead);

      expect(provider.notifications.first.isRead, true);
      expect(provider.unreadCount, 1);

      // Gọi lại lần nữa với id không tồn tại không làm crash
      provider.markAsRead('unknown');
      expect(provider.unreadCount, 1);
    });
  });
}

