import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/features/chat_bot_view_home/presentation/widgets/chat_input_area.dart';
import 'package:diet_tracking_project/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: child),
    );
  }

  testWidgets('ChatInputArea renders and handles input', (tester) async {
    final controller = TextEditingController();
    bool sendPressed = false;
    String? submittedMessage;

    await tester.pumpWidget(wrap(
      ChatInputArea(
        messageController: controller,
        onSendPressed: () => sendPressed = true,
        onMessageSubmitted: (msg) => submittedMessage = msg,
      ),
    ));

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Hello Bot');
    expect(controller.text, 'Hello Bot');

    // Tap send
    await tester.tap(find.byIcon(Icons.send));
    expect(sendPressed, isTrue);

    // Submit text
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submittedMessage, 'Hello Bot');
  });
}
