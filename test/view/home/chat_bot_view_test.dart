import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/pages/chat_bot_page.dart';

void main() {
  testWidgets('ChatBotPage hiển thị tin nhắn mặc định và toggle options', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChatBotPage()));

    // Có title
    expect(find.text('Diet Assistant'), findsOneWidget);
    // Có tin nhắn mặc định từ bot
    expect(find.textContaining('Xin chào!'), findsOneWidget);

    // Toggle options
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('gợi ý món ăn'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();
    expect(find.text('gợi ý món ăn'), findsNothing);
  });

  testWidgets('ChatBotPage chặn xuống dòng: không gửi tin nhắn', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ChatBotPage()));

    // Nhập message có xuống dòng -> snackbar
    await tester.enterText(find.byType(TextField), 'hello\nworld');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump(const Duration(milliseconds: 200));
    // Không kỳ vọng SnackBar cụ thể; xác nhận tin nhắn chứa xuống dòng không được thêm
    expect(find.text('hello\nworld'), findsNothing);

    // Không kiểm tra gửi tin nhắn hợp lệ để tránh HTTP trong test
  });
}
