import 'package:diet_tracking_project/widget/health/health_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renders with hint text and controller', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthTextField(
            controller: controller,
            hintText: 'Enter text',
          ),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Enter text'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Hello');
    expect(controller.text, 'Hello');
  });

  testWidgets('Calls onSubmitted when text is submitted', (tester) async {
    String? submittedText;
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HealthTextField(
            controller: controller,
            hintText: 'Enter text',
            onSubmitted: (text) => submittedText = text,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Submitted');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submittedText, 'Submitted');
  });
}
