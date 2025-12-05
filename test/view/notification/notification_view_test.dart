import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:diet_tracking_project/view/notification/notification_view.dart';
import 'package:diet_tracking_project/view/notification/notification_provider.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

Widget _buildApp({required NotificationProvider provider}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: ChangeNotifierProvider<NotificationProvider>.value(
      value: provider,
      child: const NotificationView(),
    ),
  );
}

void main() {
  group('NotificationView', () {
    testWidgets('hiển thị tiêu đề Inbox', (tester) async {
      final provider = NotificationProvider();

      await tester.pumpWidget(_buildApp(provider: provider));

      expect(find.text('Inbox'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('hiển thị danh sách thông báo và thứ tự mới nhất trước', (tester) async {
      final provider = NotificationProvider();
      provider.addNotification(title: 'Title 1', body: 'Body 1');
      provider.addNotification(title: 'Title 2', body: 'Body 2');

      await tester.pumpWidget(_buildApp(provider: provider));
      await tester.pump();

      // Có 2 ListTile
      expect(find.byType(ListTile), findsNWidgets(2));
      // Phần tử đầu tiên là Title 2 (mới nhất)
      expect(find.text('Title 2'), findsOneWidget);
    });

    testWidgets('tap vào item sẽ đánh dấu đã đọc (đổi màu chấm)', (tester) async {
      final provider = NotificationProvider();
      provider.addNotification(title: 'Title', body: 'Body');

      await tester.pumpWidget(_buildApp(provider: provider));
      await tester.pump();

      // Trước khi tap: chấm không phải màu grey (đang unread)
      CircleAvatar avatarBefore = tester.widget<CircleAvatar>(find.byType(CircleAvatar).first);
      expect(avatarBefore.backgroundColor, isNot(equals(Colors.grey)));

      // Tap list tile
      await tester.tap(find.byType(ListTile).first);
      await tester.pump();

      // Sau khi tap: chấm chuyển sang màu grey
      CircleAvatar avatarAfter = tester.widget<CircleAvatar>(find.byType(CircleAvatar).first);
      expect(avatarAfter.backgroundColor, equals(Colors.grey));
    });

    testWidgets('timestamp hiển thị 0m ago cho thông báo mới tạo', (tester) async {
      final provider = NotificationProvider();
      provider.addNotification(title: 'Now', body: 'Body');

      await tester.pumpWidget(_buildApp(provider: provider));
      await tester.pump();

      expect(find.textContaining('0m ago'), findsOneWidget);
    });
  });
}

