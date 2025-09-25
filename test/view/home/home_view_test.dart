import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/view/home/home_view.dart';

void main() {
  testWidgets('HomeView chuyển trang bằng BottomNavigationBar', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeView()));

    // Mặc định tab 0 'Trang chủ' (tiêu đề AppBar)
    expect(find.widgetWithText(AppBar, 'Trang chủ'), findsOneWidget);
    expect(find.text('Nội dung Trang chủ (đang phát triển)'), findsOneWidget);

    // Chuyển sang tab 1 'Ghi nhận'
    await tester.tap(find.byIcon(Icons.note_add_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ghi nhận'), findsOneWidget);
    expect(find.text('Trang ghi nhận (đang phát triển)'), findsOneWidget);

    // Không chuyển sang tab 'Hồ sơ' để tránh khởi tạo Firebase trong ProfileView
    expect(find.text('Hồ sơ'), findsWidgets);
  });
}
