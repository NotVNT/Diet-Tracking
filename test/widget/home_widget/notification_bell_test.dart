import 'package:badges/badges.dart' as badges;
import 'package:diet_tracking_project/widget/home_widget/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestWidget({int count = 0, required VoidCallback onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: NotificationBell(notificationCount: count, onTap: onTap),
      ),
    );
  }

  testWidgets('Renders icon and calls onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(buildTestWidget(onTap: () => tapped = true));

    expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);

    await tester.tap(find.byType(NotificationBell));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('Hides badge when notification count is 0', (tester) async {
    await tester.pumpWidget(buildTestWidget(onTap: () {}));

    final badge = tester.widget<badges.Badge>(find.byType(badges.Badge));
    expect(badge.showBadge, isFalse);
  });

  testWidgets('Shows badge with correct count when notifications exist', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(count: 5, onTap: () {}));

    expect(find.text('5'), findsOneWidget);
  });
}
