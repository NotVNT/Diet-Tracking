import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diet_tracking_project/common/app_confirm_dialog.dart';

void main() {
  group('AppConfirmDialog (minimal)', () {
    testWidgets('renders with title and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppConfirmDialog(title: 'Title', message: 'Message'),
            ),
          ),
        ),
      );

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('helper returns true on confirm', (WidgetTester tester) async {
      bool? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    result = await showAppConfirmDialog(
                      context,
                      title: 'Confirm',
                      message: 'Proceed?',
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });
}
